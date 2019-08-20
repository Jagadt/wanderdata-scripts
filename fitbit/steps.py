import argparse
import fitbit
import common
import datetime
import os
import pandas as pd
import requests

parser = argparse.ArgumentParser()
parser.add_argument('--access_token', '-at', help="Fitbit Access Token", type=str)
parser.add_argument('--refresh_token', '-rt', help="Fitbit Refresh Token", type=str)
args = parser.parse_args()
access_token = args.access_token
refresh_token = args.refresh_token

client = fitbit.Fitbit(os.environ['FITBIT_KEY'], os.environ['FITBIT_SECRET'],
                       access_token=access_token, refresh_token=refresh_token,
                       system='en_DE')

common.append_to_csv('data/steps_intraday', common.get_intraday_steps_data(client, '2019-07-09', '2019-08-02'))