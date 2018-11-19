import os
import csv
import shutil
import json
import math

fieldnames = ['min_speed','max_speed','delay','spacing','min_angle','max_angle','num_rows','min_b_scale','max_b_scale','clear_threshold','hard_clear_threshold', 'burst_spacing', 'burst_spacing_dur', 'burst_spacing_ratio', 'bskip_hang']

for course_type in ['density','speed']:
    for pattern_dir in os.listdir(os.path.join('1',course_type)):
        full_pattern_dir = os.path.join('1',course_type, pattern_dir)
        if not os.path.isdir(full_pattern_dir):
            continue
        out_dir = os.path.join('2',course_type, pattern_dir)
        if not os.path.isdir(out_dir):
            os.mkdir(out_dir)

        in_meta_fn = os.path.join(full_pattern_dir, 'metadata.json')
        out_meta_fn = os.path.join(out_dir, 'metadata.json')

        in_stage_fn = os.path.join(full_pattern_dir, 'stages.txt')
        out_stage_fn = os.path.join(out_dir, 'stages.txt')

        with open(in_meta_fn, 'r') as f:
            d = json.load(f)
        title = list(d['title'])
        title[1] = '2'
        d['title'] = ''.join(title)
        d['pattern type'] = '2'
        with open(out_meta_fn, 'w') as f:
            json.dump(d, f)

        with open(in_stage_fn,'r') as f:
            reader = csv.DictReader(f)
            with open(out_stage_fn, 'w') as f:
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                for row in reader:
                    for var in ['min_speed', 'max_speed', 'delay', 'spacing', 'min_angle', 'max_angle']:
                        row[var] = float(row[var])
                    row['min_speed'] = row['min_speed']*.95
                    row['max_speed'] = row['max_speed']*.95
                    row['delay'] = row['delay']*1.3
                    row['spacing'] = row['spacing']*1.05
                    row['min_angle'] = row['min_angle'] + math.pi
                    row['max_angle'] = row['max_angle'] + math.pi
                    writer.writerow(row)

