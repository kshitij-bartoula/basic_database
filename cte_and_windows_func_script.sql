CREATE TABLE public.votes
(
    voter varchar(10),
    election_year smallint,
    election_type varchar(2),
    party varchar(3)
);

INSERT INTO votes
    (voter, election_year, election_type, party)
VALUES
    ('2435871347', 2018, 'PO', 'EV'),
    ('2435871347', 2018, 'RU', 'EV'),
    ('2435871347', 2018, 'GE', 'EV'),
    ('2435871347', 2016, 'PO', 'EV'),
    ('2435871347', 2016, 'GE', 'EV'),
    ('10215121/8', 2016, 'GE', 'ED');
   
select * from public.votes;
    
WITH
cte
AS
(
SELECT ctid,
       row_number() OVER (PARTITION BY voter,
                                       election_year
                          ORDER BY voter) rn
       FROM votes
)
DELETE FROM votes
       USING cte
       WHERE cte.rn > 1
             AND cte.ctid = votes.ctid;
             
            