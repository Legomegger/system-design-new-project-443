# Замер after-index

## Условия опыта

- дата: 2026-10-27 15:48:06Z
- коммит: 9e3f5b8
- ядер у docker: 16
- память docker: 16730976256 байт
- лимиты app: 500000000 nanocpus, 536870912 байт
- сценарий: load/mixed.ts
- профиль: load/profile.json

## Итоги прогона

Числа в reports/after-index.json.
scenarios: (100.00%) 4 scenarios, 480 max VUs, 45s max duration (incl. graceful stop):
              * warmup: 5.00 iterations/s for 10s (maxVUs: 5-30, exec: read, gracefulStop: 30s)
              * history: 5.00 iterations/s for 30s (maxVUs: 20-150, exec: history, startTime: 10s, gracefulStop: 5s)
              * orders: 5.00 iterations/s for 30s (maxVUs: 20-150, exec: order, startTime: 10s, gracefulStop: 5s)
              * reads: 20.00 iterations/s for 30s (maxVUs: 20-150, exec: read, startTime: 10s, gracefulStop: 5s)



  █ THRESHOLDS

    dropped_iterations
    ✓ 'count==0' count=0

    http_req_duration{scenario:history}
    ✓ 'p(95)<30000' p(95)=2.62ms

    http_req_failed
    ✓ 'rate<=0.1' rate=0.00%


  █ TOTAL RESULTS

    checks_total.......: 954     23.845548/s
    checks_succeeded...: 100.00% 954 out of 954
    checks_failed......: 0.00%   0 out of 954

    ✓ trip is read
    ✓ history is read
    ✓ trip is created

    HTTP
    http_req_duration..............: avg=2.62ms min=1.29ms med=1.91ms max=16.38ms p(90)=5.92ms p(95)=6.65ms
      { expected_response:true }...: avg=2.62ms min=1.29ms med=1.91ms max=16.38ms p(90)=5.92ms p(95)=6.65ms
      { scenario:history }.........: avg=2.24ms min=1.55ms med=2.14ms max=10.71ms p(90)=2.5ms  p(95)=2.62ms
    http_req_failed................: 0.00%  0 out of 954
    http_reqs......................: 954    23.845548/s

    EXECUTION
    dropped_iterations.............: 0      0/s
    iteration_duration.............: avg=2.87ms min=1.58ms med=2.15ms max=17.04ms p(90)=6.28ms p(95)=6.9ms
    iterations.....................: 954    23.845548/s
    vus............................: 0      min=0        max=0
    vus_max........................: 65     min=65       max=65

    NETWORK
    data_received..................: 1.1 MB 26 kB/s
    data_sent......................: 103 kB 2.6 kB/s



## Вывод
С составным индексом passenger_id, created_at поиск истории ускорился. Решено оставить индекс
