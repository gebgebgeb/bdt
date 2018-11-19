import csv
import os
import numpy as np
import json
from pyexcel_ods import get_data

PATTERN_TYPE = '4'
COURSE_TYPE = 'density'
DATA_DIR = os.path.join(PATTERN_TYPE, COURSE_TYPE)

fieldnames = ['min_speed','max_speed','delay','spacing','min_angle','max_angle','num_rows','min_b_scale','max_b_scale','clear_threshold','hard_clear_threshold', 'burst_spacing', 'burst_spacing_dur', 'burst_spacing_ratio', 'bskip_hang']

# ods to csv
book = get_data(os.path.join(DATA_DIR, 's5_data.ods'))
data = list(book.values())[0]
with open('tmp.csv','w') as f:
    writer = csv.writer(f)
    for row in data:
        writer.writerow(row)

with open('tmp.csv','r') as f:
    reader = csv.DictReader(f)
    for s5row in reader:
        if 'X' in s5row.values():
            break
        s5row['num_rows'] = int(s5row['num_rows'])
        for key in ['adjusted_spacing', 'adjusted_delay*speed', 'b_size', 'avg_speed']:
            s5row[key] = float(s5row[key])

        l1_adj_spacing = s5row['adjusted_spacing']*1.1 + 30
        l10_adj_spacing = max(s5row['adjusted_spacing']*.9-10, 1)
        adj_spacings = list(
            np.append(np.linspace(
                l1_adj_spacing, s5row['adjusted_spacing'], num=4, endpoint=False
                ), np.linspace(
                s5row['adjusted_spacing'], l10_adj_spacing, num=6, endpoint=True
                ))
            )
        l1_adj_delay = s5row['adjusted_delay*speed']*1.1 + 30
        l10_adj_delay = max(s5row['adjusted_delay*speed']*.9-10, 1)
        adj_delays = list(
            np.append(np.linspace(
                l1_adj_delay, s5row['adjusted_delay*speed'], num=4, endpoint=False
                ), np.linspace(
                s5row['adjusted_delay*speed'], l10_adj_delay, num=6, endpoint=True
                ))
            )
        delays = []
        spacings = []
        for adj_spacing, adj_delay in zip(adj_spacings, adj_delays):
            delays.append((adj_delay+s5row['b_size'])/s5row['avg_speed'])
            spacings.append(adj_spacing + s5row['b_size'])

        out_dir = os.path.join(DATA_DIR, 'pattern' + s5row['pattern'])
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        with open(os.path.join(out_dir, 'metadata.json'),'w') as f:
            json.dump({
                'title':'(%sD%s) Pattern %s' % (
                    PATTERN_TYPE
                    , s5row['pattern'].zfill(2)
                    , s5row['pattern'].zfill(2)
                    )
                , 'pattern type': PATTERN_TYPE
                , 'course type': COURSE_TYPE
                }, f)
        out_fn = os.path.join(out_dir, 'stages.txt')
        with open(out_fn, 'w') as outf:
            writer = csv.DictWriter(outf, fieldnames = fieldnames)
            writer.writeheader()
            for i in range(10):
                out_data = {
                        'delay': delays[i]
                        , 'spacing': spacings[i]
                        , 'clear_threshold': 2000
                        , 'hard_clear_threshold': 4000
                        }
                for fieldname in fieldnames:
                    if fieldname not in out_data:
                        out_data[fieldname] = s5row[fieldname]
                writer.writerow(out_data)
