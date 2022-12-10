create database QLGTRINH

use QLGTRINH


create table GIAOTRINH (
	MAGT char(5), 
	TENGT nvarchar(50), 
	TCLT tinyint check (TCLT >= 0), 
	TCTH tinyint check (TCTH >= 0),
	primary key (MAGT)
)
create table GIANGVIEN (
	MAGV char(5), 
	TENGV nvarchar(50), 
	PHAI bit
	primary key (MAGV)
)
create table BIENSOAN(
	MAGV char(5), 
	MAGT char(5), 
	LAN tinyint, 
	NGAYBD date, 
	NGAYNOP date default NULL,
	primary key (LAN,MAGV,MAGT),
	foreign key (MAGV) references GIANGVIEN(MAGV),
	foreign key (MAGT) references GIAOTRINH(MAGT)
)

insert into GIAOTRINH values ('GT001', 'CSDL', 3,1)
insert into GIAOTRINH values ('GT002', 'PTTKHT', 2,1)
insert into GIAOTRINH values ('GT003', N'Hệ QTCSDL', 2,1)
insert into GIAOTRINH values ('GT004', 'Oracle', 2,0)
insert into GIAOTRINH values ('GT005', N'Thương mại điện tử',2,1)

select * from GIAOTRINH

insert into GIANGVIEN values ('KVH01',N'Võ Hoàng Khang',1)
insert into GIANGVIEN values ('ACT02',N'Cao Tùng Anh',1)
insert into GIANGVIEN values ('DTN03',N'Trần Ngọc Dân',1)
insert into GIANGVIEN values ('TNB04',N'Nguyễn Bạch Thanh Tùng',1)
insert into GIANGVIEN values ('HLT05',N'Trương Thị Hồng Linh',0)

select * from GIANGVIEN

set dateformat dmy

insert into BIENSOAN values ('KVH01','GT003',2,	'1/10/2014','1/1/2015')
insert into BIENSOAN values ('KVH01','GT004',1,'15/10/2015', null)
insert into BIENSOAN values ('DTN03','GT002',2,	'15/10/2015','1/1/2016')
insert into BIENSOAN values ('KVH01',	'GT002',	2,	'15/10/2015',	'1/1/2016')
insert into BIENSOAN values ('ACT02',	'GT001',	1	,'10/1/2015',	'30/5/2016')
insert into BIENSOAN values ('TNB04'	,'GT005'	,1	,'10/1/2015','30/5/2016')
select * from BIENSOAN
Câu 2) (2 điểm)
Xây dựng view có tên V1 liệt kê tên giảng viên đã đăng ký tham gia biên soạn giáo trình ít nhất. Hiển thị: Tên GV, Phái (Ghi rõ Nam/Nữ), Tổng số GT.
create view V1 as 
select top 1 with ties GIANGVIEN.MAGV,TENGV, CASE 
			  when PHAI = 0 then 'Nu'
			  else 'Nam'
			  end as Phai, COUNT(BIENSOAN.MAGT) as [Tong So GT]
from GIANGVIEN, BIENSOAN
where GIANGVIEN.MAGV = BIENSOAN.MAGV
GROUP BY GIANGVIEN.MAGV, TENGV, PHAI
ORDER BY COUNT(BIENSOAN.MAGT)
select  * from V1 
Câu 3) (2 điểm)
Viết hàm F1 cho phép đếm tổng số giảng viên đã tham gia biên soạn giáo trình X nào đó với X là mã số giáo trình, nếu X không truyền vào thì trả về 0.
create function F1 (@x varchar(5)) 
returns int 
as 
begin
	declare @sum int = 0
	select @sum = COUNT(MAGV)
	from BIENSOAN
	where MAGT = @x 
	group by MAGT
	return @sum
end
print(dbo.F1('GT001'))
Câu 4) (2 điểm)
Viết thủ tục P1 có tham số đầu vào là Mã số giáo trình (MAGT). Thủ tục cho phép liệt kê: Tên giáo trình, Tổng số GV biên soạn (bằng cách gọi hàm F1 ở trên). Nếu mã số giáo trình không truyền vào thì in ra tất cả các giáo trình đã đăng ký.
alter proc P1 @x varchar(5)
as 
if @x is null
begin
	select * from BIENSOAN
end 
else
begin
	select distinct TENGT, dbo.F1(@x) as [Tong So GV]
	from BIENSOAN, GIAOTRINH	
	where BIENSOAN.MAGT = GIAOTRINH.MAGT and GIAOTRINH.MAGT = @x 
end
exec P1 'GT002'
Câu 5) (2 điểm)
Mỗi lần biên soạn, mỗi cuốn giáo trình không cho phép hơn 2 GV cùng tham gia viết. Hãy xây dựng trigger có tên T1 đảm bảo ràng buộc này.
create trigger T1 ON BIENSOAN 
for insert, update 
as 
begin 
	declare @x int = 0, @ma varchar(5)
	select @ma = MAGT
	from inserted
	group by MAGT
	select @x = count(MAGV)
	from BIENSOAN
	where MAGT = @ma
	group by MAGT
	if (@x > 2)
	begin
		print 'So giao vien soan giao trinh khong duoc qua 2'
		rollback tran
	end 
end 
set dateformat dmy
insert into BIENSOAN values ('ACT02','GT002',1,	'11/1/2015','29/5/2016')
