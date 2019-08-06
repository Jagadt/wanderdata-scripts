import os.path
import pandas as pd
import datetime

# TODO: pls rename this file


def append_to_csv(filename, df):
    should_write_header = not os.path.exists('{}.csv'.format(filename))
    with open('{}.csv'.format(filename), 'a+') as f:
        df.to_csv(f, header=should_write_header, index=False)


def get_sleep_data(client, base_date):
    """
    This function retrieves sleep data, from base_date until todat
    """
    # get sleep data
    start = datetime.datetime.strptime(base_date, '%Y-%m-%d')
    delta = datetime.datetime.today() - start
    dates = [start + datetime.timedelta(days=i) for i in range(delta.days + 1)]
    sleep_data = []

    for date in dates:
            single_day_sleep = client.get_sleep(date.date())
            for sleep_activity in single_day_sleep.get('sleep'):
                    if not sleep_activity.get('isMainSleep'):
                            continue
                    sleep_data.append((sleep_activity.get('dateOfSleep'),
                                       sleep_activity.get('efficiency'), 
                                       sleep_activity.get('startTime'), 
                                       sleep_activity.get('endTime'),
                                       sleep_activity.get('timeInBed'),
                                       sleep_activity.get('minutesAsleep')))

    return pd.DataFrame(sleep_data, columns=['date', 'efficiency', 'startTime', 
                        'endTime', 'timeInBed', 'minutesAsleep'])
