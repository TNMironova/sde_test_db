create table if not exists bookings.results 
(id INT, 
response TEXT);
insert into bookings.results 
select 1 as id,  max(pre.count_passengers) as response
from (
select bookings.book_ref, count(tickets.passenger_id) as count_passengers
from bookings join tickets on bookings.book_ref = tickets.book_ref
group by bookings.book_ref) pre;
--id=2
insert into bookings.results 
with pre1 as (select bookings.book_ref, count(tickets.passenger_id) as count_passengers
from bookings join tickets on bookings.book_ref = tickets.book_ref
group by bookings.book_ref),
pre2 as(select avg(pre1.count_passengers) as avg_passengers
from pre1)
select 2 as id, count(pre1.book_ref) as response
from pre1,pre2
where pre1.count_passengers>avg_passengers;
--id=3
insert into bookings.results 
with 
tt as (select bookings.book_ref, count(tickets.passenger_id) as count_passengers
from bookings join tickets on bookings.book_ref = tickets.book_ref
group by bookings.book_ref),
tt1 as(select tt.book_ref from tt where tt.count_passengers in (select max(tt.count_passengers) from tt)),
tt2 as (select pre2.book_ref, STRING_AGG(pre2.passenger_id,'|' order by pre2.rn) as strr from (
select tickets.book_ref, tickets.passenger_id, row_number() over(partition by tickets.book_ref order by tickets.passenger_id) as rn
from tickets join tt1 on tt1.book_ref=tickets.book_ref) pre2
group by pre2.book_ref)
select 3 as id, sum(tt3.resp) as response
from(select count(tt2.book_ref) as resp
from tt2
group by tt2.strr
having count(tt2.book_ref)>=2
order by tt2.strr) tt3;
--id=4
insert into bookings.results 
with pre as(select bookings.book_ref, count(tickets.passenger_id) as count_passengers
from bookings join tickets on bookings.book_ref = tickets.book_ref
group by bookings.book_ref
having count(tickets.passenger_id)=3)
select 4 as id, pre.book_ref||'|'||passenger_id||'|'||passenger_name||'|'||contact_data as response
from pre 
left join tickets on pre.book_ref = tickets.book_ref
order by pre.book_ref,passenger_id,passenger_name,contact_data;
--id=5
insert into bookings.results 
select 5 as id, max(count_flight_id) as response
from(select bookings.book_ref, count(ticket_flights.flight_id) as count_flight_id
from bookings join tickets on bookings.book_ref = tickets.book_ref
join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
group by bookings.book_ref) pre;
--id=6
insert into bookings.results 
select 6 as id, max(count_flight_id) as response
from(select bookings.book_ref, tickets.passenger_id, count(ticket_flights.flight_id) as count_flight_id
from bookings join tickets on bookings.book_ref = tickets.book_ref
join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
group by bookings.book_ref, tickets.passenger_id) pre;
--id=7
insert into bookings.results 
select 7 as id, max(count_flight_id) as response
from(select tickets.passenger_id, count(ticket_flights.flight_id) as count_flight_id
from tickets 
join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
group by tickets.passenger_id) pre;
--id=8
insert into bookings.results 
with tt1 as (select tickets.passenger_id, tickets.passenger_name,tickets.contact_data,sum(ticket_flights.amount) as amount
from tickets 
join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
group by tickets.passenger_id, tickets.passenger_name,tickets.contact_data)
select 8 as id, tt1.passenger_id||'|'||tt1.passenger_name||'|'||tt1.contact_data||tt1.amount as response
from tt1
where tt1.amount in (select min(tt1.amount) from tt1) 
order by tt1.passenger_id, tt1.passenger_name, tt1.contact_data, tt1.amount;
--id=9
insert into bookings.results 
with tt1 as (select tickets.passenger_id, tickets.passenger_name,tickets.contact_data,sum(actual_duration) as sum_time
from tickets 
join ticket_flights on tickets.ticket_no = ticket_flights.ticket_no
join flights_v on ticket_flights.flight_id = flights_v.flight_id
group by tickets.passenger_id, tickets.passenger_name,tickets.contact_data)
select 9 as id, tt1.passenger_id||'|'||tt1.passenger_name||'|'||tt1.contact_data||tt1.sum_time as response
from tt1
where tt1.sum_time in (select max(tt1.sum_time) from tt1) 
order by tt1.passenger_id, tt1.passenger_name, tt1.contact_data, tt1.sum_time;
--id=10
insert into bookings.results 
select 10 as id, pre.city as response
from(
select city, count(airport_code) as count_airports 
from airports
group by city) pre
where pre.count_airports>1
order by pre.city;
--id=11
insert into bookings.results 
with tt as(select pre.city1, count(distinct pre.city2) as count_city
from (select departure_city as city1, arrival_city as city2
from routes
union all
select arrival_city, departure_city
from routes) pre
group by pre.city1)
select 11 as id, tt.city1 as response
from tt
where tt.count_city in (select min(tt.count_city) from tt)
order by tt.city1;
--id=12
insert into bookings.results 
with tt1 as(select air1.city as city1, air2.city as city2
from airports air1, airports air2
EXCEPT select distinct pre.city1, pre.city2
from (select departure_city as city1, arrival_city as city2
from routes
union all
select arrival_city, departure_city
from routes) pre)
select 12 as id, pre2.ind as response
from (select distinct pre1.ind from (
select tt1.city1||'|'||tt1.city2 as ind 
from tt1 where tt1.city1!=tt1.city2
and tt1.city1<tt1.city2 
) pre1) pre2
order by pre2.ind;
--id=13
insert into bookings.results 
with pre as(
select distinct 'Москва' as city1, airports.city as city2 
from airports where airports.city!='Москва'
EXCEPT select routes.departure_city as city1, routes.arrival_city as city2
from routes where departure_city='Москва')
select 13 as id, pre.city2 as response
from pre
order by pre.city2;
--id=14
insert into bookings.results 
with pre as(select flights.aircraft_code, count(flights.flight_id) as count_flight
from flights where flights.status = 'Arrived'
group by flights.aircraft_code)
select 14 as id, aircrafts.model as response
from aircrafts join pre on aircrafts.aircraft_code = pre.aircraft_code 
where count_flight in (select max(count_flight) from pre);
--id=15
insert into bookings.results 
with pre as(select flights.aircraft_code, count(tickets.passenger_id) as count_passengers
from flights join ticket_flights on flights.flight_id = ticket_flights.flight_id 
join tickets on tickets.ticket_no = ticket_flights.ticket_no 
where flights.status = 'Arrived'
group by flights.aircraft_code)
select 15 as id, aircrafts.model as response
from aircrafts join pre on aircrafts.aircraft_code = pre.aircraft_code 
where count_passengers in (select max(count_passengers) from pre);
--id=16
insert into bookings.results 
select 16 as id, sum(extract(epoch from flights_v.actual_duration-flights_v.scheduled_duration)/60) as response
from flights_v
where flights_v.status='Arrived';
--id=17
insert into bookings.results 
select 17 as id, flights_v.arrival_city as response
from flights_v
where flights_v.departure_city='Санкт-Петербург'
and actual_departure::date=to_date('2017-08-01', 'yyyy-mm-dd')
and flights_v.status='Arrived'
group by flights_v.arrival_city;
--id=18
insert into bookings.results 
with pre as (select flights.flight_id,  sum(ticket_flights.amount) as amount
from flights join ticket_flights on flights.flight_id = ticket_flights.flight_id 
group by flights.flight_id)
select 18 as id, pre.flight_id as response
from pre
where pre.amount in (select max(pre.amount) from pre);
--id=19
insert into bookings.results 
with pre as (select extract(dow from (flights.actual_departure)) as weekd, count(flights.flight_id) as count_flights from flights
where flights.status = 'Arrived'
group by extract(dow from (flights.actual_departure)))
select 19 as id, weekd from pre as response
where count_flights = (select min(count_flights) from pre)
order by weekd;
--id=20
insert into bookings.results 
with pre as(select flights_v.actual_departure::date, count(flights_v.flight_id) as count_flights
from flights_v
where flights_v.departure_city='Москва'
and flights_v.status in ('Departed', 'Arrived')
and extract(year from (flights_v.actual_departure)) =2016
and extract(month  from (flights_v.actual_departure)) =9
group by flights_v.actual_departure::date)
select 20 as id, avg(count_flights) as response
from pre;
--id=21
insert into bookings.results 
with pre as(select flights_v.departure_city , avg(flights_v.actual_duration)
from flights_v
where extract(epoch from actual_duration)/60/60>3
and flights_v.status = 'Arrived'
group by flights_v.departure_city
order by avg(flights_v.actual_duration) desc
limit 5)
select 21 as id, pre.departure_city as response
from pre order by pre.departure_city;



