create database Music_store;
use music_store;
select * from album2;
# 1. Who is the senior most employee based on jobtitle
select * from employee order by levels desc limit 1;

# 2.  Which countries have the most Invoices?
select count(*) as c, billing_country from invoice group by billing_country order by c desc;


# 3. What are top 3 values of total invoice?
select * from invoice order by total desc limit 3 ;

/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made 
the most money. Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals
*/
select sum(total) as invoice_total,billing_city from invoice group by billing_city order by invoice_total desc limit 1;
select * from invoice;

/*5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money
*/
SELECT c.customer_id, c.first_name,c.last_name, SUM(i.total) AS totals
FROM customer c 
JOIN invoice i ON c.customer_id = i.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name 
ORDER BY totals DESC 
LIMIT 1;

/*Question Set 2 – Moderate
1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A
*/
select * from customer;
select * from album2;
select * from artist;
select * from genre;
select * from track;
select * from invoice;
select * from invoice_line;

select distinct c.email,c.first_name,c.last_name 
from customer c join invoice i on c.customer_id = i.customer_id 
join invoice_line l on i.invoice_id = l.invoice_id 
join track t on l.track_id = t.track_id 
join genre g on t.genre_id = g.genre_id
where g.name="rock"
order by email;



/*
2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands
*/

select a.artist_id,a.name,count(a.artist_id) as no_of_songs
from artist a join album2 l on a.artist_id = l.artist_id join track t on l.album_id = t.album_id
where genre_id in (select genre_id from genre where name = "rock")
group by a.artist_id,a.name
order by no_of_songs desc;

/*
3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
*/

select name,milliseconds  from track 
where milliseconds > (select avg(milliseconds) from track)
group by name,milliseconds
order by milliseconds
desc;

/*
Question Set 3 – Advance
1. Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent
*/

with best_selling as
(select ar.artist_id as artist_id,ar.name as artist_name,sum(il.unit_price*il.quantity) 
as total_sales
from invoice_line il join track t on il.track_id=t.track_id
join album2 a on t.album_id=a.album_id 
join artist ar on a.artist_id = ar.artist_id
group by 1,2
order by total_sales desc
limit 1)
select c.first_name,c.last_name,bs.artist_id,bs.artist_name,
sum(il.unit_price*il.quantity) as sales
from customer c 
join invoice i on c.customer_id=i.customer_id 
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id = t.track_id
join album2 al on t.album_id = al.album_id 
join best_selling bs on al.artist_id = bs.artist_id
group by 1,2,3,4
order by 5 desc
;

/*
2. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres
*/
with popular_genre as
(
select count(il.quantity) as purchases, c.country,g.name,g.genre_id,row_number() over(partition by c.country
order by count(il.quantity) desc) as rowno from invoice_line il
join invoice i on i.invoice_id = il.invoice_id
join customer c on c.customer_id = i.customer_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre where rowno <=1; 


/*
3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
*/
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

