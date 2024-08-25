#!/usr/bin/env python3
# -*- coding:utf-8 -*-

REDIS_PASSWORD = ''
POSTGRESQL_USER = ''
POSTGRESQL_DBNAME = ''
POSTGRESQL_PASSWORD = ''

BROKER_IP = ''


broker_url = f'redis://:{REDIS_PASSWORD}@{BROKER_IP}:6379/0'
result_backend = f'redis://:{REDIS_PASSWORD}@{BROKER_IP}:6379/0'
broker_connection_retry_on_startup = True

task_routes = {
    'scanner.scan_ports': {'queue': 'scan_queue'},
    'scanner.store_result': {'queue': 'store_queue'},
    'scanner.scan_service_finger_print': {'queue': 'scan_queue'},
}