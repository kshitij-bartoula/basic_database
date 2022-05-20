CREATE TABLE equipments (
    id bigint NOT NULL,
    name character varying(255),
    "timestamp" timestamp without time zone,
    value character varying(255),
    CONSTRAINT equipments_pkey PRIMARY KEY (id)
);

INSERT INTO equipments VALUES
  (15,'sensor2','2015-01-03 22:02:05.872','88.4')
, (16,'foo27'  ,'2015-01-03 22:02:10.887','-3.755')
, (17,'sensor1','2015-01-03 22:02:10.887','1.1704')
, (18,'foo27'  ,'2015-01-03 22:02:50.825','-1.4')
, (19,'bar_18' ,'2015-01-03 22:02:50.833','545.43')
, (20,'foo27'  ,'2015-01-03 22:02:50.935','-2.87')
, (21,'sensor3','2015-01-03 22:02:51.044','6.56');

select * from equipments;


CREATE EXTENSION tablefunc;
SELECT *
    FROM
        crosstab(
            'SELECT
                equipments."timestamp",
                equipments.name,
                equipments.value
            FROM
                public.equipments
            ORDER BY
                1'
            ,
            'SELECT
                DISTINCT
                equipments.name
            FROM
                public.equipments
            ORDER BY
                1'
        )
    AS
        (
            "timestamp" timestamp without time zone,
            "sensor1" character varying(255),
            "sensor2" character varying(255),
            "sensor3" character varying(255),
            "foo27" character varying(255),
            "bar_18" character varying(255)
            
        )
    ;
    
