import fitbit
import os
import argparse
import datetime
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('--base_date', '-bd', help="Starting date", type=str,
                    default='2019-05-28')
args = parser.parse_args()


def run():
    # use Germany locale so the units are in the metric system
    client = fitbit.Fitbit(os.environ['FITBIT_KEY'],
                           os.environ['FITBIT_SECRET'],
                           access_token=os.environ['ACCESS_TOKEN'],
                           refresh_token=os.environ['REFRESH_TOKEN'],
                           system='en_DE')
    base_date = args.base_date
    df = get_sleep_data(client, base_date)
    df.to_csv('data/df.csv', index=False, encoding='utf-8')


def get_sleep_data(client, base_date):
    """
    This function retrieves sleep data, from base_date until today
    """
    # get sleep data
    start = datetime.datetime.strptime(base_date, '%Y-%m-%d')
    delta = datetime.datetime.today() - start
    dates = [start + datetime.timedelta(days=i) for i in range(delta.days + 1)]
    sleep_data = []

    for date in dates:
        single_day_sleep = client.get_sleep(date.date())
        stages = single_day_sleep.get('summary').get('stages')
        for sleep_activity in single_day_sleep.get('sleep'):
            # ignore naps
            if not sleep_activity.get('isMainSleep'):
                continue
            levels = sleep_activity.get('summary')
            sleep_data.append((sleep_activity.get('dateOfSleep'),
                               sleep_activity.get('efficiency'),
                               sleep_activity.get('startTime'),
                               sleep_activity.get('endTime'),
                               sleep_activity.get('timeInBed'),
                               sleep_activity.get('minutesAsleep'),
                               sleep_activity.get('restlessCount'),
                               sleep_activity.get('minutesAfterWakeup'),
                               sleep_activity.get('minutesToFallAsleep'),
                               sleep_activity.get('minutesAwake'),
                               sleep_activity.get('restlessDuration'),
                               stages.get('deep'),
                               stages.get('light'),
                               stages.get('rem'),
                               stages.get('wake')))

    return pd.DataFrame(sleep_data, columns=['date', 'efficiency', 'startTime',
                                             'endTime', 'timeInBed',
                                             'minutesAsleep',
                                             'restlessCount',
                                             'minutesAfterWakeup',
                                             'minutesToFallAsleep',
                                             'minutesAwake',
                                             'restlessDuration', 'deep',
                                             'light', 'rem', 'wake'])


if __name__ == "__main__":
    print('Starting....')
    run()
