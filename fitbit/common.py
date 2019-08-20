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


def get_intraday_steps_data(client, start_date, end_date):
    start = datetime.datetime.strptime(start_date, '%Y-%m-%d')
    end = datetime.datetime.strptime(end_date, '%Y-%m-%d')
    delta = end - start
    dates = [start + datetime.timedelta(days=i) for i in range(delta.days + 1)]
    steps_data = []
    for date in dates:
        single_day_steps = client.intraday_time_series('activities/steps', base_date=date, detail_level='15min')
        for entry in single_day_steps.get('activities-steps-intraday').get('dataset'):
            steps_data.append((date, entry.get('time'), entry.get('value')))

    return pd.DataFrame(steps_data, columns=['date', 'time', 'value'])
