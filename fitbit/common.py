import os.path
import pandas as pd


def append_to_csv(filename, df):
    should_write_header = False if os.path.exists(filename) else True
    with open('{}.csv'.format(filename), 'a+') as f:
        df.to_csv(f, header=should_write_header, index=False)
