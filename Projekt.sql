SET LANGUAGE polski


create table Gracz
(Nick varchar(20) primary key,
Punkty_rankingowe bigint default 0,
Liczba_zab�jstw bigint default 0,
Liczba_zgon�w bigint default 0,
Pieni�dze bigint default 30000,
Liczba_zwyci�stw bigint default 0)

create table Mecz
(Id_Mecz int not null primary key IDENTITY(1,1),
Data_meczu date,
Zwyciezca varchar(20) not null)

create table Czo�g
 (Id_Czo�g int not null primary key identity (1,1),
 nazwa varchar(25),
 cena int)

 create table dodatki
 (iddod int not null primary key identity (1,1),
 cena int,
 nazwa varchar(30))

 create table Gra
 (Gracz varchar(20) references Gracz(Nick),
 Id_Czo�g int not null references Czo�g(Id_Czo�g),
 Dodatek int not null references Dodatki (iddod),
 Id_Mecz int not null references Mecz(Id_Mecz),
 Kille int ,
  Liczba_pieni�dzy bigint )

 create table Ulepszenie
  (Czo�g int references Czo�g (Id_Czo�g),
 Dodatki int references dodatki(iddod))

 create table Posiadanie
 (Nick varchar(20) references Gracz(Nick),
 Dodatek int references dodatki(iddod),
 Czo�g int references Czo�g(Id_Czo�g))

 create table transakcje
 (idtran int not null primary key identity (1,1),
 Nick varchar(20) not null references Gracz(Nick),
 Kwota money not null,
 Pieniadze int)

 create table cennik
 (Kwota money ,
 Pieniadze int)





 
 
select * from Gra
select * from Gracz
select * from Mecz
select * from Czo�g
select * from dodatki
select * from Ulepszenie
select * from Posiadanie
select * from transakcje
select * from cennik

 drop table Gracz
 drop table Mecz
 drop table Czo�g
 drop table dodatki
 drop table Gra
 drop table Ulepszenie
 drop table Posiadanie
 drop table transakcje
 drop table cennik

 insert into posiadanie 
 values ('Leibnitz',2,2)
----------------------------------------------------------------------------------
						   Trigersy
----------------------------------------------------------------------------------
 create trigger dziesiec
 on gra
 for insert
 as
 if (select count(g.id_mecz) from  gra g join inserted i on i.id_mecz=g.id_mecz) =11
 print '10 graczy w meczu juz jest'
  if (select count(g.id_mecz) from  gra g join inserted i on i.id_mecz=g.id_mecz) =11
rollback
---------------------------------------------------------------
 create trigger dwoch_graczy
 on gra
 for insert
 as
  if (select count(g.gracz) from  gra g join inserted i on g.gracz=i.gracz
   join mecz m on m.id_mecz=g.id_mecz  where i.id_mecz=m.id_mecz) >=2
  print 'ten sam gracz nie mo�e gra� 2 razy w danym meczu'
 if (select count(g.gracz) from  gra g join inserted i on i.gracz=g.gracz
   join mecz m on m.id_mecz=g.id_mecz where i.id_mecz=m.id_mecz ) >=2
rollback
-------------------------------------------------------------------------
create trigger Licz
on Gracz
after update
as
update Gracz
set Gracz.Punkty_rankingowe = (Gracz.Liczba_zab�jstw * 50) / (Gracz.Liczba_zgon�w + 1)
-------------------------------------------------------------------------
 create trigger szesc
 on posiadanie 
 for insert
 as
  if (select count(p.nick) from  posiadanie p join inserted i on i.nick=p.nick) =7
print 'Masz juz 6 czolgow'
 if (select count(p.nick) from  posiadanie p join inserted i on i.nick=p.nick) =7
rollback
------------------------------------------------------------
create trigger brak_kasy
on posiadanie
after insert
as
If
(select g.pieni�dze from gracz g join inserted i on i.nick=g.nick ) <
 (select c.cena from czo�g c join inserted i on c.id_czo�g=i.czo�g)
 print 'Masz za ma�o pieniedzy' 
If (select g.Pieni�dze from gracz g join inserted i on i.nick=g.nick ) <
 (select c.cena from czo�g c join inserted i on c.id_czo�g=i.czo�g)
 rollback
--------------------------------------------------------------------------
create trigger dosyc_kasy
on posiadanie
after insert
as
If (select g.Pieni�dze from gracz g join inserted i on i.nick=g.nick ) >
 (select c.cena from czo�g c join inserted i on c.id_czo�g=i.czo�g)+
  (select d.cena from dodatki d join inserted i on d.iddod=i.dodatek)
 update Gracz set pieni�dze=g.pieni�dze-c.cena-d.cena 
 from czo�g c join inserted i on i.czo�g=c.id_czo�g 
 join gracz g on i.nick=g.nick
 join dodatki d on d.iddod=i.dodatek
 If (select g.Pieni�dze from gracz g join inserted i on i.nick=g.nick ) >
 (select c.cena from czo�g c join inserted i on c.id_czo�g=i.czo�g)+
  (select d.cena from dodatki d join inserted i on d.iddod=i.dodatek)
 print 'Czo�g kupiony'

 select * from dodatki
 select * from posiadanie

---------------------------------------------------------------  

create trigger sprawdzdod
	on Posiadanie
	for insert
	as
	if not (select dodatek from inserted)  in 
	(select u.dodatki from Ulepszenie u 
	join inserted i 
	on u.czo�g=i.czo�g)
	 print ' Danego dodatku nie mo�na zainstalowa�'
	 	if not (select dodatek from inserted)  in 
	(select u.dodatki from Ulepszenie u 
	join inserted i 
	on u.czo�g=i.czo�g)
	rollback
	
-----------------------------------------------------------------
	create trigger sprawdzkille
	on gra
	for insert
	as
	if (select sum(g.kille) from gra g  join  inserted i on g.id_mecz=i.id_mecz ) >=9
	 and
    (select m.zwyciezca from mecz m  join inserted i on m.Id_Mecz = i.Id_Mecz) not in 
	(select g.gracz from gra g join inserted i on g.id_mecz=i.id_mecz)
	print 'za duzo zabojstw' 
	if (select sum(g.kille) from gra g join  inserted i on g.id_mecz=i.id_mecz ) >=9 AND
    (select m.zwyciezca from mecz m join inserted i on m.Id_Mecz = i.Id_Mecz) not in 
	(select g.gracz from gra g join inserted i on g.id_mecz=i.id_mecz)
	rollback
	if (select sum(g.kille) from gra g  join  inserted i on g.id_mecz=i.id_mecz ) >=10
	 
	print 'za duzo zabojstw' 
	if (select sum(g.kille) from gra g join  inserted i on g.id_mecz=i.id_mecz ) >=10 
    
	rollback
-------------------------------------------------------------------------------------------------------

	create trigger dodaj_kase
	on gra
	after update
	as
	update gr set pieni�dze= gr.pieni�dze+ i.liczba_pieni�dzy from gracz gr , inserted i where gr.nick=i.gracz
	
------------------------------------------------------------------------------------------------------------
	create trigger dodaj_kille
	on gra
	after insert
	as
	update gr set liczba_zab�jstw= gr.liczba_zab�jstw+ i.kille from gracz gr , inserted i where gr.nick=i.gracz	

	select * from gra
-------------------------------------------------------------------------------------------------------------	
	create trigger dodaj_zgony
	on gra 
	after insert
	as
	if (select i.gracz from inserted i) not in (select zwyciezca from mecz join inserted i on mecz.id_mecz=i.id_mecz)
	update gracz set liczba_zgon�w= gracz.liczba_zgon�w+1 from gracz,inserted where gracz.nick=inserted.gracz
-----------------------------------------------------------------------------------------------------------	 
	create trigger liczba_zwyci�stw
	on gra 
	after insert
	as
	if (select i.gracz from inserted i)  in (select zwyciezca from mecz join inserted i on mecz.id_mecz=i.id_mecz)
	update gracz set liczba_zwyci�stw= gracz.liczba_zwyci�stw+1 from gracz,inserted where gracz.nick=inserted.gracz 
--------------------------------------------------------------------------------------------------------------
	
	create trigger piniodz1
	on gra
	after insert
	as
	if (select i.gracz from inserted i) not in (select zwyciezca from mecz join inserted i on mecz.id_mecz=i.id_mecz)
	update gra set liczba_pieni�dzy= gra.kille*30 +50 from gra join inserted i on i.id_mecz=gra.id_mecz where gra.gracz=i.gracz 
	-------------------------------------------------------------------------------------------------------------
	create trigger piniodz2
	on gra
	after insert
	as
	if (select i.gracz from inserted i)  in (select zwyciezca from mecz join inserted i on mecz.id_mecz=i.id_mecz)
	update gra set liczba_pieni�dzy= gra.kille*50 +150 from gra join inserted i on i.id_mecz=gra.id_mecz where gra.gracz=i.gracz
	-------------------------------------------------------------------------------------------------------------

	create trigger sprawdz_czo�g
	on gra
	after insert
	as
	if not (select i.dodatek from inserted i)  in 
	(select p.dodatek from posiadanie p
	join inserted i 
	on p.czo�g=i.id_czo�g
	where i.gracz=p.nick)
	print 'Nie masz takiego czo�gu w posiadanych ' 
    if not (select i.dodatek from inserted i)  in 
	(select p.dodatek from posiadanie p
	join inserted i 
	on p.czo�g=i.id_czo�g
	where i.gracz=p.nick)
	rollback
	------------------------------------------------------------------------------------------------------------
	create trigger przelicz
	on transakcje
	after insert
	as
	if (select i.kwota from inserted i) in  (select i.kwota from inserted i join cennik c on i.kwota=c.kwota)
	update transakcje set pieniadze=c.pieniadze from cennik c 
	join inserted i on  c.kwota=i.kwota 
	join transakcje t on t.kwota=i.kwota  
	where i.idtran=t.idtran

   ------------------------------------------------------------------------------------------------------------
create trigger przeslij
	on transakcje 
	after update
	as
	update gr set pieni�dze= gr.pieni�dze+ i.pieniadze from gracz gr , inserted i where gr.nick=i.nick


	select * from transakcje
----------------------------------------------------------------------------------------------------------------

 drop trigger sprawdzdod
 drop trigger dziesiec
 drop trigger dwoch_graczy
 drop trigger licz
 drop trigger szesc
 drop trigger dosyc_kasy
 drop trigger brak_kasy
 drop trigger sprawdzkille
 drop trigger dodaj_kille
 drop trigger dodaj_zgony
 drop trigger dodaj_kase
 drop trigger liczba_zwyci�stw
 drop trigger piniodz1
 drop trigger piniodz2
 drop trigger sprawdz_czo�g
 drop trigger przelicz
 drop trigger przeslij

-------------------------------------------------------------------------------
                       Procki
-------------------------------------------------------------------------------
 create procedure Nowy_viewgracz
@Nick varchar(20),

@Id_Gracza int OUTPUT
as
begin
set @Id_Gracza = (select count(Nick) from Gracz);
set @Id_Gracza+=1;
insert into viewGracz values (@Nick);
end
declare @x int
exec nowy_viewgracz 'aadfaga',@x output
select * from viewgracz
-------------------------------------------------------------------------------
 create procedure Nowy_viewgra

 @Gracz varchar(20),
 @id_czo�g int ,
 @dodatek int ,
 @id_mecz int,
 @kille int 
 as
 begin
 insert into viewgra values (@gracz,@id_czo�g,@dodatek,@id_mecz,@kille)
 END

 declare @x int
exec nowy_viewgra 'kumajka',2,2,1,7 
select * from mecz
select * from gra
select * from gracz
delete from gra where gracz='kumajka'


drop procedure nowy_viewgra
 select * from viewgra
 select * from gra
-------------------------------------------------------------------------------
 create procedure nowy_mecz
@Data_meczu datetime,
@zwyciezca varchar(20) ,

@Id_mecz int OUTPUT
as
begin
set @Id_mecz = (select count(id_mecz) from Mecz);
set @Id_mecz+=1;
insert into mecz values (@data_meczu,@zwyciezca);
end


declare @x int
exec nowy_mecz '19-03-2012','Dirichlet',@x 
select * from mecz
-----------------------------------------------------------------------
create procedure posiadaniee
@Nick varchar(20),
@Dodatek int,
@Czo�g int
as
begin
insert into posiadanie values (@nick,@czo�g,@dodatek)
end

declare @x int 
exec posiadaniee 'Kumajka',2,2
select * from gracz
select * from cennik
-----------------------------------------------------------------------
create procedure Ulepszenia
	 @Czo�g int,
	 @Dodatki int
	 as
	 begin
	 insert into Ulepszenie values (@Czo�g, @Dodatki)
	 end
declare @x int 
exec ulepszenia 2,6

drop procedure nowy_mecz
select * from posiadanie
select * from ulepszenie

create procedure nowy_tran
 @Nick varchar (20),
 @Kwota money
 as
 begin
 insert into viewtran values (@Nick,@kwota)
 end

 declare @x int
 exec nowy_tran 'Kumajka',26


 select * from transakcje

 create procedure cenniczek
@Kwota money,
@Pieniadze int
 as
 begin
 insert into cennik values (@Kwota,@pieniadze)
 end

 declare @x int
 exec cenniczek 120,9500

 select * from cennik

drop procedure nowy_tran

 -----------------------------------------------------------------------
                    Funkcje
 -----------------------------------------------------------------------
 create function ranking_graczy
(@top int)
returns @ranking table
(
Nick varchar(20),
Punkty_rankingowe bigint,
Liczba_zab�jstw bigint,
liczba_zgon�w bigint,
Pieni�dze money,
Liczba_zwyci�stw bigint)
AS
BEGIN
INSERT @ranking
SELECT TOP (@top) Nick, Punkty_rankingowe, Liczba_zab�jstw, Liczba_zgon�w, Pieni�dze, Liczba_zwyci�stw
FROM Gracz
ORDER BY Punkty_Rankingowe DESC
RETURN
END
drop function ranking_graczy

select * from ranking_graczy(10)
----------------------------------------------------------------------------------------------
create function Liczba
	(@Gracz varchar(20))
	returns bigint
	as
	begin
	return (select count(@Gracz)  from Gra where @gracz= gra.gracz)
	end

	select [LABS\s396602].Liczba('Kumajka')  as 'liczba gier'
-----------------------------------------------------------------------------------------------
create function Kaman
        (@s bigint)
        returns table
as
        return select Gracz from Gra where Id_Mecz = @s

	select * from kaman(3)

drop function ranking_graczy
drop function liczba
---------------------------------------------------------------------------------------------------
                           Widoki
---------------------------------------------------------------------------------------------------
create view Viewgracz (gracz)
as
select nick from gracz

select * from viewgracz
---------------------------------------------------------------------------------------------------
create view viewgra (gracz,id_czo�g,dodatek,id_mecz,kille)
as 
select gracz,id_czo�g,dodatek,id_mecz,kille from gra



select * from viewgra 

drop view viewgra
---------------------------------------------------------------------------------------------------
create view viewtran (Nick,kwota)
as
select Nick,kwota from transakcje
----------------------------------------------------------------------------------------------------
                              Wysypisko �mieci
----------------------------------------------------------------------------------------------------

 insert into czo�g (nazwa,cena)
 values ('M4Sherman',20000)
  insert into czo�g (nazwa,cena)
 values ('Jaguar',23510)
  insert into czo�g (nazwa,cena)
 values ('Panthera',23000)
  insert into czo�g (nazwa,cena)
 values ('T1 Heavy',15000)
  insert into czo�g (nazwa,cena)
 values ('KV1',22000)
  insert into czo�g (nazwa,cena)
 values ('KV2',26000)
  insert into czo�g (nazwa,cena)
 values ('PZKpvw',23000)
  insert into czo�g (nazwa,cena)
 values ('Tygrys',21000)
  insert into czo�g (nazwa,cena)
 values ('T34',20000)
  insert into czo�g (nazwa,cena)
 values ('Chi Ha',17000)
  insert into czo�g (nazwa,cena)
 values ('AT 8',15000)
  insert into czo�g (nazwa,cena)
 values ('MK IV Churchill',22000)
  insert into czo�g (nazwa,cena)
 values ('TOG 2',20000)
  insert into czo�g (nazwa,cena)
 values ('ErykW',100000)
  insert into czo�g (nazwa,cena)
 values ('M8',21000)
 insert into czo�g (nazwa,cena)
 values ('Dzielny Tabuluga',22000)
  insert into czo�g (nazwa,cena)
 values ('Pikachu',22000)


 select * from gracz
 delete from gracz where nick='Cauchy'
 insert into Gracz(Nick)
values ('Kumajka')
insert into Gracz(Nick)
values ('Talinek')
insert into Gracz(Nick)
values ('Sokrates')
insert into Gracz(Nick)
values ('Tales')
insert into Gracz(Nick)
values ('Cytryn 6')
insert into Gracz(Nick)
values ('adielf')
insert into Gracz(Nick)
values ('F3AR 666')
insert into Gracz(Nick)
values ('BGTBG IPMBP')
insert into Gracz(Nick)
values ('Sorakte')
insert into Gracz(Nick)
values ('Kubaskejt')
insert into Gracz(Nick)
values ('Adrianskejt')
insert into Gracz(Nick)
values ('Stachuskejt')
insert into Gracz(Nick)
values ('IFFEK I TYLE')
insert into Gracz(Nick)
values ('Cauchy')
insert into Gracz(Nick)
values ('Bernoulli')
insert into Gracz(Nick)
values ('Gauss')
insert into Gracz(Nick)
values ('Leibnitz')
insert into Gracz(Nick)
values ('Newton')
insert into Gracz(Nick)
values ('Abel')
insert into Gracz(Nick)
values ('Dirichlet')
insert into Gracz(Nick)
values ('Bot')

 
 select * from dodatki
 insert into dodatki(nazwa,cena)
 values ('Kamufla�',3000)
 insert into dodatki(nazwa,cena)
 values ('Litr w�dki',20)
 insert into dodatki(nazwa,cena)
 values ('Hadronowe dzia�o',5000)
 insert into dodatki(nazwa,cena)
 values ('Karabin mysznowy',2000)
  insert into dodatki(nazwa,cena)
 values ('Wzmocniony pancerz',1400)
  insert into dodatki(nazwa,cena)
 values ('Robot kierowca',2122)
 insert into dodatki(nazwa,cena)
 values ('Niezniszczalna wie�a',3111)
  insert into dodatki(nazwa,cena)
 values ('Krasnoludek mechanik',2600)
  insert into dodatki(nazwa,cena)
 values ('Celownik laserowy',4155)
 insert into dodatki(nazwa,cena)
 values ('G�sienica g�adka jazda',3111)
  insert into dodatki(nazwa,cena)
 values ('Super pociski',2600)
  insert into dodatki(nazwa,cena)
 values ('Silnik Diesla',4350)
 insert into dodatki (nazwa,cena)
 values ('Radar',1870)

 insert into ulepszenie (czo�g,dodatki)
 values (1,1)
 insert into ulepszenie (czo�g,dodatki)
 values (1,2)
 insert into ulepszenie (czo�g,dodatki)
 values (1,5)
 insert into ulepszenie (czo�g,dodatki)
 values (1,6)
 insert into ulepszenie (czo�g,dodatki)
 values (1,8)
 insert into ulepszenie (czo�g,dodatki)
 values (1,10)
 insert into ulepszenie (czo�g,dodatki)
 values (1,12)
 insert into ulepszenie (czo�g,dodatki)
 values (1,13)
 insert into ulepszenie (czo�g,dodatki)
 values (2,2)
 insert into ulepszenie (czo�g,dodatki)
 values (2,5)
 insert into ulepszenie (czo�g,dodatki)
 values (2,7)
 insert into ulepszenie (czo�g,dodatki)
 values (2,11)
 insert into ulepszenie (czo�g,dodatki)
 values (2,12)
 insert into ulepszenie (czo�g,dodatki)
 values (2,13)
 insert into ulepszenie (czo�g,dodatki)
 values (3,1)
 insert into ulepszenie (czo�g,dodatki)
 values (3,2)
 insert into ulepszenie (czo�g,dodatki)
 values (3,3)
 insert into ulepszenie (czo�g,dodatki)
 values (3,6)
 insert into ulepszenie (czo�g,dodatki)
 values (3,9)
 insert into ulepszenie (czo�g,dodatki)
 values (3,11)
 insert into ulepszenie (czo�g,dodatki)
 values (3,12)
 insert into ulepszenie (czo�g,dodatki)
 values (4,2)
 insert into ulepszenie (czo�g,dodatki)
 values (4,4)
 insert into ulepszenie (czo�g,dodatki)
 values (4,7)
 insert into ulepszenie (czo�g,dodatki)
 values (4,8)
 insert into ulepszenie (czo�g,dodatki)
 values (4,9)
 insert into ulepszenie (czo�g,dodatki)
 values (5,2)
 insert into ulepszenie (czo�g,dodatki)
 values (5,6)
 insert into ulepszenie (czo�g,dodatki)
 values (5,12)
 insert into ulepszenie (czo�g,dodatki)
 values (5,8)
 insert into ulepszenie (czo�g,dodatki)
 values (6,1)
 insert into ulepszenie (czo�g,dodatki)
 values (6,2)
 insert into ulepszenie (czo�g,dodatki)
 values (6,3)
 insert into ulepszenie (czo�g,dodatki)
 values (6,5)
 insert into ulepszenie (czo�g,dodatki)
 values (6,7)
 insert into ulepszenie (czo�g,dodatki)
 values (6,10)
 insert into ulepszenie (czo�g,dodatki)
 values (7,1)
 insert into ulepszenie (czo�g,dodatki)
 values (7,2)
 insert into ulepszenie (czo�g,dodatki)
 values (7,7)
 insert into ulepszenie (czo�g,dodatki)
 values (7,10)
 insert into ulepszenie (czo�g,dodatki)
 values (7,12)
  insert into ulepszenie (czo�g,dodatki)
 values (8,2)
  insert into ulepszenie (czo�g,dodatki)
 values (8,4)
  insert into ulepszenie (czo�g,dodatki)
 values (8,5)
  insert into ulepszenie (czo�g,dodatki)
 values (8,8)
  insert into ulepszenie (czo�g,dodatki)
 values (8,10)
  insert into ulepszenie (czo�g,dodatki)
 values (8,12)
  insert into ulepszenie (czo�g,dodatki)
 values (9,2)
 insert into ulepszenie (czo�g,dodatki)
 values (9,3)
 insert into ulepszenie (czo�g,dodatki)
 values (9,5)
 insert into ulepszenie (czo�g,dodatki)
 values (9,9)
 insert into ulepszenie (czo�g,dodatki)
 values (9,11)
 insert into ulepszenie (czo�g,dodatki)
 values (9,12)
 insert into ulepszenie (czo�g,dodatki)
 values (10,2)
 insert into ulepszenie (czo�g,dodatki)
 values (10,5)
 insert into ulepszenie (czo�g,dodatki)
 values (10,7)
 insert into ulepszenie (czo�g,dodatki)
 values (10,10)
 insert into ulepszenie (czo�g,dodatki)
 values (10,12)
 insert into ulepszenie (czo�g,dodatki)
 values (10,13)
 insert into ulepszenie (czo�g,dodatki)
 values (11,2)
 insert into ulepszenie (czo�g,dodatki)
 values (11,3)
 insert into ulepszenie (czo�g,dodatki)
 values (11,6)
 insert into ulepszenie (czo�g,dodatki)
 values (11,7)
 insert into ulepszenie (czo�g,dodatki)
 values (11,11)
 insert into ulepszenie (czo�g,dodatki)
 values (11,13)
 insert into ulepszenie (czo�g,dodatki)
 values (12,1)
  insert into ulepszenie (czo�g,dodatki)
 values (12,2)
  insert into ulepszenie (czo�g,dodatki)
 values (12,9)
  insert into ulepszenie (czo�g,dodatki)
 values (12,13)
  insert into ulepszenie (czo�g,dodatki)
 values (13,2)
 insert into ulepszenie (czo�g,dodatki)
 values (13,3)
 insert into ulepszenie (czo�g,dodatki)
 values (13,6)
 insert into ulepszenie (czo�g,dodatki)
 values (13,7)
 insert into ulepszenie (czo�g,dodatki)
 values (13,8)
 insert into ulepszenie (czo�g,dodatki)
 values (13,9)
 insert into ulepszenie (czo�g,dodatki)
 values (14,1)
 insert into ulepszenie (czo�g,dodatki)
 values (14,2)
 insert into ulepszenie (czo�g,dodatki)
 values (14,3)
 insert into ulepszenie (czo�g,dodatki)
 values (14,4)
 insert into ulepszenie (czo�g,dodatki)
 values (14,8)
 insert into ulepszenie (czo�g,dodatki)
 values (15,2)
  insert into ulepszenie (czo�g,dodatki)
 values (15,3)
  insert into ulepszenie (czo�g,dodatki)
 values (15,6)
  insert into ulepszenie (czo�g,dodatki)
 values (15,8)
  insert into ulepszenie (czo�g,dodatki)
 values (15,10)
  insert into ulepszenie (czo�g,dodatki)
 values (15,12)
  insert into ulepszenie (czo�g,dodatki)
 values (15,13)
  insert into ulepszenie (czo�g,dodatki)
 values (16,2)
 insert into ulepszenie (czo�g,dodatki)
 values (16,6)
 insert into ulepszenie (czo�g,dodatki)
 values (16,8)
 insert into ulepszenie (czo�g,dodatki)
 values (16,11)
 insert into ulepszenie (czo�g,dodatki)
 values (16,13)
 insert into ulepszenie (czo�g,dodatki)
 values (17,1)
  insert into ulepszenie (czo�g,dodatki)
 values (17,2)
  insert into ulepszenie (czo�g,dodatki)
 values (17,9)
  insert into ulepszenie (czo�g,dodatki)
 values (17,10)
  insert into ulepszenie (czo�g,dodatki)
 values (17,12)

 insert into mecz (Data_meczu, Zwyciezca)
 values('31-12-2000', 'Kumajka' )
  insert into mecz (Data_meczu, ZWYCIEZCA)
 values('30-12-2000', 'Gauss' )
  insert into mecz (Data_meczu, ZWYCIEZCA)
 values('31-12-2000', 'Talinek' )
 select * from mecz
 insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Newton' ,4,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Gauss' ,5,3)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Leibnitz' ,1,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Kumajka' ,4,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Talinek' ,5,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Sorakte' ,5,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Aaaa' ,5,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Dirichlet' ,5,7)
  insert into posiadanie (Nick,czo�g,Dodatek)
 values ('Cauchy' ,5,7)

 insert into gra (gracz,id_czo�g,id_mecz,kille) 
 values ('Talinek',3,1,0)
  insert into gra 
 values ('Gauss',2,14,0,30,60)
  insert into gra 
 values ('Kumajka',1,14,0,30,60)