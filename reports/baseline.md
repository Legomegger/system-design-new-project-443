# Замер baseline

## Условия опыта

- дата: 2026-10-27 15:25:55Z
- коммит: eb07e8b
- ядер у docker: 16
- память docker: 16730976256 байт
- лимиты app: 500000000 nanocpus, 536870912 байт
- сценарий: load/mixed.ts
- профиль: load/profile.json

## Итоги прогона

scenarios: (100.00%) 4 scenarios, 480 max VUs, 45s max duration (incl. graceful stop):
              * warmup: 5.00 iterations/s for 10s (maxVUs: 5-30, exec: read, gracefulStop: 30s)
              * history: 5.00 iterations/s for 30s (maxVUs: 20-150, exec: history, startTime: 10s, gracefulStop: 5s)
              * orders: 5.00 iterations/s for 30s (maxVUs: 20-150, exec: order, startTime: 10s, gracefulStop: 5s)
              * reads: 20.00 iterations/s for 30s (maxVUs: 20-150, exec: read, startTime: 10s, gracefulStop: 5s)



  █ THRESHOLDS

    dropped_iterations
    ✓ 'count==0' count=0

    http_req_duration{scenario:history}
    ✓ 'p(95)<30000' p(95)=88.97ms

    http_req_failed
    ✓ 'rate<=0.1' rate=0.00%


  █ TOTAL RESULTS

    checks_total.......: 954     23.804777/s
    checks_succeeded...: 100.00% 954 out of 954
    checks_failed......: 0.00%   0 out of 954

    ✓ trip is read
    ✓ trip is created
    ✓ history is read

    HTTP
    http_req_duration..............: avg=15.13ms min=1.33ms  med=2.02ms  max=113.09ms p(90)=78.33ms p(95)=82.41ms
      { expected_response:true }...: avg=15.13ms min=1.33ms  med=2.02ms  max=113.09ms p(90)=78.33ms p(95)=82.41ms
      { scenario:history }.........: avg=80.13ms min=69.87ms med=79.81ms max=113.09ms p(90)=85.76ms p(95)=88.97ms
    http_req_failed................: 0.00%  0 out of 954
    http_reqs......................: 954    23.804777/s

    EXECUTION
    dropped_iterations.............: 0      0/s
    iteration_duration.............: avg=15.4ms  min=1.44ms  med=2.29ms  max=113.69ms p(90)=78.73ms p(95)=82.68ms
    iterations.....................: 954    23.804777/s
    vus............................: 0      min=0        max=0
    vus_max........................: 65     min=65       max=65

    NETWORK
    data_received..................: 1.1 MB 26 kB/s
    data_sent......................: 103 kB 2.6 kB/s


## Вывод

TODO: что упёрлось в предел и по какому признаку это видно.

taxi=# EXPLAIN (ANALYZE, BUFFERS)
taxi-# SELECT * FROM trips where passenger_id = 1;
                                                        QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..65590.82 rows=200 width=327) (actual time=0.310..72.828 rows=200.00 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   Buffers: shared hit=15906 read=38247
   ->  Parallel Seq Scan on trips  (cost=0.00..64570.82 rows=83 width=327) (actual time=0.996..64.120 rows=66.67 loops=3)
         Filter: (passenger_id = 1)
         Rows Removed by Filter: 666650
         Buffers: shared hit=15906 read=38247
 Planning Time: 0.080 ms
 Execution Time: 72.889 ms
(10 rows)


Без индекса по passenger_id используется SEQ SCAN. Можно добавить составной индекс по пассажиру и created_at
