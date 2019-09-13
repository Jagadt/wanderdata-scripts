import argparse
import fitbit
import common
import datetime
import os
import pandas as pd
import requests

parser = argparse.ArgumentParser()
parser.add_argument('--base_date', '-bd', help="Starting date", type=str,
                    default='2019-09-03')
parser.add_argument('--access_token', '-at', help="Fitbit Access Token", type=str)
parser.add_argument('--refresh_token', '-rt', help="Fitbit Refresh Token", type=str)
args = parser.parse_args()
base_date = args.base_date
access_token = args.access_token
refresh_token = args.refresh_token

# key and secrets are kept as env variables
client = fitbit.Fitbit(os.environ['FITBIT_KEY'], os.environ['FITBIT_SECRET'],
                       access_token=access_token, refresh_token=refresh_token,
                       system='en_DE')


# get water logs
result = client.time_series(resource='foods/log/water', base_date=base_date, 
                            end_date='today')
df = pd.DataFrame(result['foods-log-water'])
common.append_to_csv('data/water', df)

# get sleep data
common.append_to_csv('data/sleep', common.get_sleep_data(client, base_date))

# activities to retrieve
activities = ['steps', 'calories', 'distance', 'minutesSedentary',
              'minutesLightlyActive', 'minutesFairlyActive',
              'minutesVeryActive', 'elevation']

# this loop gets the activities data, convert it to DataFrame and saves it to csv
for act in activities:
    result = client.time_series(resource='activities/{}'.format(act),
                                base_date=base_date, end_date='today')
    df = pd.DataFrame(result['activities-{}'.format(act)])
    common.append_to_csv('data/{}'.format(act), df)
