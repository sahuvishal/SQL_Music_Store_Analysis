--Q1:who is the senior most employee based on job title?
select * from employee
order by hire_date
limit 1;
--Q2:which country have the most Invoices?
select billing_country,count(*) as cnt  from invoice
group by billing_country
order by cnt desc
limit 1;
--Q3:what are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;
/*--Q4 Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/
select billing_city,sum(total) as s
from invoice
group by billing_city
order by s desc
limit 1;
/*Q5:Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/
select a.first_name,sum(b.total) as s
from customer a,invoice b
where a.customer_id=b.customer_id
group by a.customer_id
order by s desc
limit 1;
--set2
/*1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/
select distinct a.email,a.first_name,a.last_name,b.name
from customer a,genre b,invoice c,invoice_line d,Track e
where a.customer_id=c.customer_id
and c.invoice_id=d.invoice_id
and e.track_id=d.track_id
and e.genre_id=b.genre_id
and b.name like '%Rock%'
order by a.email;

select a.artist_id,a.name,count(a.artist_id) as songs
from artist a,album b,Track c,Genre d
where a.artist_id=b.artist_id
and b.album_id=c.album_id
and c.genre_id=d.genre_id
and d.name like'%Rock%'
group by a.artist_id
order by songs
limit 10;
/*return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/


select name,milliseconds as l from track
where milliseconds>(select avg(milliseconds)
from track)
order by l desc;

/*Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

with best_selling_track as (select d.artist_id,d.name,sum(a.unit_price*a.Quantity)
from invoice_line a join track b on a.track_id=b.track_id
join album c on b.album_id=c.album_id
join artist d on d.artist_id=c.artist_id
group by 1,2
order by 3 desc
limit 1)

select a.customer_id,a.first_name,a.last_name,bst.name,sum(c.unit_price*c.Quantity)
from customer a
join invoice b on a.customer_id=b.customer_id
join invoice_line c on c.invoice_id=b.invoice_id
join track d on d.track_id=c.track_id
join album e on e.album_id=d.album_id
join best_selling_track bst on bst.artist_id=e.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1