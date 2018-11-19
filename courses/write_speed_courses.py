import csv
import os
import numpy as np
import json
from pyexcel_ods import get_data

PATTERN_TYPE = '1'
COURSE_TYPE = 'speed'
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
        for key in ['min_speed', 'max_speed', 'delay*speed']:
            s5row[key] = float(s5row[key])

        l1_min_speed = s5row['min_speed']*.9 - 2.5
        l1_max_speed = s5row['max_speed']*.9 - 2.5
        l10_min_speed = s5row['min_speed']*1.1+1.5
        l10_max_speed = s5row['max_speed']*1.1+1.5

        min_speeds = list(
                np.append(np.linspace(
                    l1_min_speed, s5row['min_speed'], num=4, endpoint=False
                    ), np.linspace(
                    s5row['min_speed'], l10_min_speed, num=6, endpoint=True
                    ))
                )
        max_speeds = list(
                np.append(np.linspace(
                    l1_max_speed, s5row['max_speed'], num=4, endpoint=False
                    ), np.linspace(
                    s5row['max_speed'], l10_max_speed, num=6, endpoint=True
                    ))
                )

        out_dir = os.path.join(DATA_DIR, 'pattern' + s5row['pattern'])
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        with open(os.path.join(out_dir, 'metadata.json'),'w') as f:
            json.dump({
                'title':'(%sS%s) Pattern %s' % (
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
                min_speed = min_speeds[i]
                max_speed = max_speeds[i]
                avg_speed = (min_speed + max_speed)/2
                delay = s5row['delay*speed'] / avg_speed
                out_data = {
                        'min_speed': min_speed
                        , 'max_speed': max_speed
                        , 'delay': delay
                        , 'clear_threshold': 2000
                        , 'hard_clear_threshold': 4000
                        }

                for fieldname in fieldnames:
                    if fieldname not in out_data:
                        out_data[fieldname] = s5row[fieldname]
                writer.writerow(out_data)
