#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author: fe1w0
from celery import Celery
import masscan
import json
import psycopg2

from scanner.config import BROKER_IP, POSTGRESQL_DBNAME, POSTGRESQL_PASSWORD, POSTGRESQL_USER

app = Celery('scanner')
app.config_from_object('scanner.config')

def get_db_connection():
    return psycopg2.connect(f"dbname={POSTGRESQL_DBNAME} user={POSTGRESQL_USER} password={POSTGRESQL_PASSWORD} host={BROKER_IP}")

def test_connection():
    try:
        conn = get_db_connection()
        print("连接成功!")
        conn.close()
    except Exception as e:
        print(f"连接失败: {e}")

@app.task
def store_result(scan_result):
    conn = get_db_connection()
    cur = conn.cursor()
    try:
        for ip, result in scan_result.items():
            json_result = json.dumps(result)
            cur.execute(
                "INSERT INTO port_results (ip, result) VALUES (%s, %s) ON CONFLICT (ip) DO UPDATE SET result = %s",
                (ip, json_result, json_result)
            )
        conn.commit()
        return f"Storing results for {scan_result} completed."
    except Exception as e:
        conn.rollback()
        return f"Error storing results: {e}, and input is {scan_result}"
    finally:
        cur.close()
        conn.close()

@app.task
def scan_ports(ip_range, ports='1-65535', rate=200):
    mas = masscan.PortScanner()
    
    # 执行扫描
    try:
        mas.scan(ip_range, ports=ports, arguments=f'--max-rate {rate}', sudo=True)
        scan_result = mas.scan_result
        
        curr_scan_result = json.loads(scan_result)['scan']
        store_result.delay(curr_scan_result)
        
        return f'Scanning {mas.command_line} completed.'
    except Exception as e:
        return f'Error scanning {ip_range}: {str(e)}'

@app.task
def scan_service_finger_print(task_info):
    print(task_info)
    return task_info