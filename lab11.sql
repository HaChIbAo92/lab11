create database QLSV
go
use QLSV
go
create table LOP
(
MALOP nvarchar(20),
TENLOP nvarchar(15),
sISO int not null,
constraint PK_LOP primary key(MALOP)
)

create table SINHVIEN
(
MASV nvarchar(20),
HOTEN nvarchar(50),
NGAYSINH datetime,
MALOP nvarchar(20),
constraint PK_SINHVIEN primary key(MASV)
)

create table MONHOC
(
MAMONHOC nvarchar(20),
TENMONHOC nvarchar(50),
constraint PK_MONHOC primary key(MAMONHOC)
)

create table KETQUA
(
MASV nvarchar(20),
MAMONHOC nvarchar(20),
DIEMTHI int,
constraint PK_KETQUA primary key (MASV, MAMONHOC)
)

--Nhập dữ liệu
insert into LOP values ('B001', 'CNTT3', 31)
insert into LOP values ('B002', 'CNTT4', 31)
insert into SINHVIEN values ('A001', N'Hà  Bảo', '11-01-2002', 'B001')
insert into SINHVIEN values ('A002', N'Hà Long', '11-10-2002', 'B002')
insert into SINHVIEN values ('A003', N'Trần Cường', '1-01-2002', 'B002')
insert into SINHVIEN values ('A004', N'Nguyễn Thành', '2-04-2000', 'B001')
insert into MONHOC values ('C001', 'HQTCSDL')
insert into MONHOC values ('C002', 'CSDLNC')
insert into KETQUA values ('A001', 'C001', 10)
insert into KETQUA values ('A002', 'C002', 8)
insert into KETQUA values ('A003', 'C001', 9)
insert into KETQUA values ('A004', 'C002', 7)

--khóa ngoại
Alter table LOP add constraint Fk_SINHVIEN FOREIGN KEY(MALOP) references LOP(MALOP)
alter table SINHVIEN add constraint fk_KETQUA foreign key(MASV) references SINHVIEN(MaSV),
alter table MONHOC add constraint fk_KETQUA foreign key(MAMONHOC) references MONHOC(MAMONHOC),


--Bài 1
go
create function diemtb (@msv char(5))
returns float
as
begin
declare @tb float
set @tb = (select avg(DIEMTHI)
from KetQua
where MaSV=@msv)

return @tb
end
go
select dbo.diemtb ('A001')

--Bài 2
create function trbinhlop1(@malop char(5))
returns @dsdiemtb table (masv char(5), tensv nvarchar(20), dtb float)
as
begin
insert @dsdiemtb
select s.masv, Hoten, trungbinh=dbo.diemtb(s.MaSV)
from Sinhvien s join KetQua k on s.MaSV=k.MaSV
where MaLop=@malop
group by s.masv, Hoten
return
end
go
select*from trbinhlop1('B001')

--Bài 3
go
create proc ktra @msv char(5)
as
begin
declare @n int
set @n=(select count(*) from ketqua where Masv=@msv)
if @n=0
print 'sinh vien '+@msv + 'khong thi mon nao'
else
print 'sinh vien '+ @msv+ 'thi '+cast(@n as char(2))+ 'mon'
end
go
exec ktra 'A003'

--Bài 4

go
create trigger updatesslop
on sinhvien
for insert
as
	begin
		declare @ss int
		set @ss=(select count(*) from sinhvien s
			where malop in(select malop from inserted))
	if @ss>10
	begin
		print 'Lop day'
		rollback tran
	end
else
	begin
		update lop
		set SiSo=@ss
		where malop in (select malop from inserted)
end