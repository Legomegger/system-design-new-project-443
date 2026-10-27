---
status: proposed
date: 2026-10-27
---

# Название решения

Файл назван по образцу `010-имя-решения.md`. Номер служит адресом, по которому на решение ссылаются из отчётов и из соседних решений.

Статус бывает `proposed` у предложенного, `accepted` у принятого, `rejected` у отклонённого и `superseded` у заменённого другим решением со ссылкой на замену.

Разделы ниже повторяют [MADR 4](https://adr.github.io/madr/), поэтому записи читаются так же, как в чужих репозиториях.

| Раздел здесь | MADR |
| --- | --- |
| Контекст и проблема | Context and Problem Statement |
| Какие варианты сравнивали | Considered Options |
| Решение | Decision Outcome |
| Последствия | Consequences |
| Подтверждение | Confirmation |

## Контекст и проблема

Что заставило принимать решение. Здесь стоят числа замера или плана запроса, из-за которых так дальше нельзя.

Без индекса:

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


Без индекса по passenger_id используется SEQ SCAN. Можно добавить составной индекс по пассажиру и created_at. Линейный поиск будет занимать все больше времени при увеличении числа поездок. Соответственно будет тратиться бюджет времени на получение данных и общее время ответа.

## Какие варианты сравнивали

Варианты вместе с причиной отказа у каждого. Причина привязана к этой системе, а не к свойствам инструмента вообще.

Без индекса - отклонено - слишком долго и неоптимизированно.
Индекс только по passenger_id:

 Sort  (cost=779.66..780.16 rows=200 width=327) (actual time=0.298..0.306 rows=200.00 loops=1)
   Sort Key: created_at DESC
   Sort Method: quicksort  Memory: 65kB
   Buffers: shared hit=203
   ->  Bitmap Heap Scan on trips  (cost=5.98..772.01 rows=200 width=327) (actual time=0.048..0.235 rows=200.00 loops=1)
         Recheck Cond: (passenger_id = 1)
         Heap Blocks: exact=200
         Buffers: shared hit=203
         ->  Bitmap Index Scan on trips_passenger_created  (cost=0.00..5.93 rows=200 width=0) (actual time=0.023..0.023 rows=200.00 loops=1)
               Index Cond: (passenger_id = 1)
               Index Searches: 1
               Buffers: shared hit=3
 Planning:
   Buffers: shared hit=18 read=6
 Planning Time: 0.315 ms
 Execution Time: 0.409 ms
(16 rows)


 Sort  (cost=779.66..780.16 rows=200 width=327) (actual time=0.380..0.387 rows=200.00 loops=1)
   Sort Key: created_at DESC
   Sort Method: quicksort  Memory: 65kB
   Buffers: shared hit=200 read=3
   ->  Bitmap Heap Scan on trips  (cost=5.98..772.01 rows=200 width=327) (actual time=0.144..0.314 rows=200.00 loops=1)
         Recheck Cond: (passenger_id = 1)
         Heap Blocks: exact=200
         Buffers: shared hit=200 read=3
         ->  Bitmap Index Scan on trips_passenger_created  (cost=0.00..5.93 rows=200 width=0) (actual time=0.125..0.125 rows=200.00 loops=1)
               Index Cond: (passenger_id = 1)
               Index Searches: 1
               Buffers: shared read=3
 Planning:
   Buffers: shared hit=20 read=1
 Planning Time: 0.404 ms
 Execution Time: 0.535 ms
(16 rows)



## Решение

Время запроса HTTP без индекса был в среднем 15мс.
С индексом 2.62
При одинаковом количестве данных и количестве запросов.

p95 без индекса на замерах в baseline.md выдал 88.97 ms, при составном индексе passenger_id, created_at: 2.62ms.
Такой же результат был при индексе только на passenger_id. 

Вывод: выбрано создание составного индекса passenger_id, created_at. Поскольку на текущих данных база выбрала делать сортировку сама. В будущем при выборке истории по пользователю и сортировке по дате создания по убыванию второй индекс created_at пригодится.



## Последствия

Создан составной индекс по полям passenger_id, created_at. 
Плюс - быстрый поиск истории по пользователю + сортировка по убыванию.
Минус - при записи новой поездки придется так же изменять структуру индекса в базе.

## Подтверждение

Решение с составным индексом работает быстрее.
Откат не рассматривается, всякий откат будет хуже.
Пересмотр индекса в случае если время на создание новой записи будет поджимать бюджет

Чем проверяем, что решение работает, и при каком признаке откатываем.
