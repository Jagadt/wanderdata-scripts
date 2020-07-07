import argparse
import datetime
import os

import fitbit
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('--access_token', '-at',
                    help="Fitbit Access Token", type=str)
parser.add_argument('--refresh_token', '-rt',
                    help="Fitbit Refresh Token", type=str)
args = parser.parse_args()
access_token = args.access_token
refresh_token = args.refresh_token


def append_to_csv(filename, df):
    """Appends the steps data to an existing file.
    If the file does not exist, it creates it.
    """

    # Write the header if the file does not exist.
    should_write_header = not os.path.exists('{}.csv'.format(filename))
    with open('{}.csv'.format(filename), 'a+') as f:
        df.to_csv(f, header=should_write_header, index=False)


def get_intraday_steps_data(client, start_date, end_date):
    """Gets the intraday steps data from start_date to end_date.
    Mind that Fitbit API only allows for 150 requests per hour per
    authorized user.
    """

    start = datetime.datetime.strptime(start_date, '%Y-%m-%d')
    end = datetime.datetime.strptime(end_date, '%Y-%m-%d')
    delta = end - start
    dates = [start + datetime.timedelta(days=i) for i in range(delta.days + 1)]
    steps_data = []

    for date in dates:
        print(date)
        single_day_steps = client.intraday_time_series(
            'activities/steps', base_date=date, detail_level='15min')
        for entry in single_day_steps.get('activities-steps-intraday').get('dataset'):
            steps_data.append((date, entry.get('time'), entry.get('value')))

    return pd.DataFrame(steps_data, columns=['date', 'time', 'value'])


if __name__ == "__main__":
    client = fitbit.Fitbit(os.environ['FITBIT_KEY'],
                           os.environ['FITBIT_SECRET'],
                           access_token=access_token,
                           refresh_token=refresh_token,
                           system='en_DE')

    df = get_intraday_steps_data(client, '2019-05-28', '2019-07-08')
    append_to_csv('data/steps_intraday', df)
