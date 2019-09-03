import argparse
import pprint
import time
import json
import requests
from google.cloud import bigquery
from google.cloud.bigquery import SchemaField

table_schema = (
        bigquery.SchemaField('lat', 'FLOAT'),
        bigquery.SchemaField('lon', 'FLOAT'),
        bigquery.SchemaField('weather_main', 'STRING'),
        bigquery.SchemaField('weather_description', 'STRING'),
        bigquery.SchemaField('temp', 'FLOAT'),
        bigquery.SchemaField('pressure', 'FLOAT'),
        bigquery.SchemaField('humidity', 'FLOAT'),
        bigquery.SchemaField('temp_min', 'FLOAT'),
        bigquery.SchemaField('temp_max', 'FLOAT'),
        bigquery.SchemaField('pressure_sea_level', 'FLOAT'),
        bigquery.SchemaField('pressure_grnd_level', 'FLOAT'),
        bigquery.SchemaField('wind_speed', 'FLOAT'),
        bigquery.SchemaField('wind_deg', 'FLOAT'),
        bigquery.SchemaField('cloudiness', 'FLOAT'),
        bigquery.SchemaField('rain_1h', 'INTEGER'),
        bigquery.SchemaField('rain_3h', 'INTEGER'),
        bigquery.SchemaField('snow_1h', 'INTEGER'),
        bigquery.SchemaField('snow_3h', 'INTEGER'),
        bigquery.SchemaField('country', 'STRING'),
        bigquery.SchemaField('sunrise', 'STRING'),
        bigquery.SchemaField('sunset', 'STRING'),
        bigquery.SchemaField('city_id', 'STRING'),
        bigquery.SchemaField('city_name', 'STRING'),
        bigquery.SchemaField('uv', 'FLOAT'),
        bigquery.SchemaField('date_iso', 'STRING'),
        bigquery.SchemaField('dt', 'INTEGER'),
        )
        
# 1 hour; how often do we want to run this
time_delay = 600.0


def prepare_bq_dataset(client, bq_dataset, table_name):
    dataset = client.dataset(bq_dataset)
    table_ref = dataset.table(table_name)
    table = bigquery.Table(table_ref, table_schema)
    try:
        client.create_table(table)
    except:
        print('Table exists')
    return table


def get_weather_data(lat, lon, client, table):
    start_time = time.time()
    # keep track of the last time an API called was performed.
    errors = None
    weather_call_url = 'https://api.openweathermap.org/data/2.5/weather?lat={}&lon={}&appid={}'.format(lat, lon, key)
    uv_call_url = 'http://api.openweathermap.org/data/2.5/uvi?appid={}&lat={}&lon={}'.format(key, lat, lon)

    while True:
        print('Executing at {}'.format(time.strftime("%Y-%m-%d %H:%M:%S",
              time.gmtime())))

        # do API calls
        weather_data_req = requests.get(weather_call_url)
        uv_data_req = requests.get(uv_call_url)

        # if the weather_data request is not ok, continue and try again later
        if not weather_data_req.ok:
            print('weather request not ok: {}'.format(weather_data_req.status_code))
            time.sleep(time_delay - ((time.time() - start_time) % time_delay))
            continue

        uv_data_value = -1
        uv_data_iso_date = ''
        # if the uv request is not ok, ignore it and proceed
        if uv_data_req.ok:
            uv_data = uv_data_req.json()
            uv_data_value = uv_data.get('value', -1)
            uv_data_iso_date = uv_data.get('date_iso', '')
            print(uv_data_value)
        else:
            print('uv data request not ok: {}'.format(uv_data_req.status_code))
            
        weather_data = weather_data_req.json()
        print(weather_data)

        # these next four fields are optional, that's why I'm using getters
        rain_1h = weather_data['rain'].get('1h', -1) if 'rain' in weather_data else -1
        rain_3h = weather_data['rain'].get('3h', -1) if 'rain' in weather_data else -1
        snow_1h = weather_data['snow'].get('1h', -1) if 'snow' in weather_data else -1
        snow_3h = weather_data['snow'].get('3h', -1) if 'snow' in weather_data else -1

        try:
            row_to_insert_in_bq = (
                weather_data['coord']['lat'], weather_data['coord']['lon'],
                weather_data['weather'][0]['main'],
                weather_data['weather'][0]['description'],
                weather_data['main']['temp'],
                weather_data['main']['pressure'],
                weather_data['main']['humidity'],
                weather_data['main']['temp_min'],
                weather_data['main']['temp_max'],
                weather_data['main'].get('sea_level', -1),  # optional
                weather_data['main'].get('grnd_level', -1),  # optional
                weather_data['wind']['speed'],
                weather_data['wind'].get('deg', -1),
                weather_data['clouds']['all'],
                rain_1h, rain_3h,
                snow_1h, snow_3h,
                weather_data['sys']['country'],
                weather_data['sys']['sunrise'],
                weather_data['sys']['sunset'],
                weather_data['id'],
                weather_data['name'],
                uv_data_value,
                uv_data_iso_date,
                weather_data['dt'],
            )
        except Exception as e:
            print('Exception: {}'.format(e))
            time.sleep(time_delay - ((time.time() - start_time) % time_delay))
            continue

        # the object to insert has to be a list of either tuples, or dict
        errors = client.insert_rows(table, (row_to_insert_in_bq,))

        if not errors:
            print('Record {} inserted'.format(row_to_insert_in_bq))
        else:
            print('Error inserting: {}'.format(errors))
        # code will be executed every time_delay seconds
        time.sleep(time_delay - ((time.time() - start_time) % time_delay))


def main(lat, lon, gcp_project, bq_dataset, table_name):
    # Instantiates a BQ Client
    client = bigquery.Client(project=gcp_project)
    table = prepare_bq_dataset(client, bq_dataset, table_name)
    get_weather_data(lat, lon, client, table)

if __name__ == '__main__':
    print('Starting...')
    parser = argparse.ArgumentParser(description='description')
    parser.add_argument('--key', help='API key')
    parser.add_argument('--lat', help='latitude')
    parser.add_argument('--lon', help='longitude')
    parser.add_argument('--gcp-project', help='Google Cloud Project')
    parser.add_argument('--bq-dataset', help='BigQuery Dataset')
    parser.add_argument('--bq-table-name', help='BigQuery Dataset Table Name')
    args = parser.parse_args()
    key = args.key
    main(args.lat, args.lon, args.gcp_project, args.bq_dataset, args.bq_table_name)
