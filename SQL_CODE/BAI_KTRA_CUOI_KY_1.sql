--le de 1, chan de 2 
create database QL_GT
use QL_GT
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
set dateformat dmy 
Câu 2) (2 điểm)
Xây dựng view có tên V2 liệt kê tên các GV chưa đăng ký tham gia viết cuốn giáo trình nào. Hiển thị: Tên GV, Phái (ghi Nam hoặc Nữ).
create view V2 as 
select TENGV, CASE 
			  when PHAI = 0 then 'Nu'
			  else 'Nam'
			  end as Phai
from GIANGVIEN
where GIANGVIEN.MAGV not in (select MAGV from BIENSOAN)
select  * from V2
Câu 3) (2 điểm)
Viết hàm F2 cho phép đếm tổng số ngày để thực hiện việc viết giáo trình X của GV Y nào đó, với X là mã số giáo trình, Y là mã số GV. (1 điểm)
create function F2 (@X char(5), @y char(5))
returns int 
as 
begin
	declare @ans int
	select @ans = DATEDIFF(day,BIENSOAN.NGAYBD,BIENSOAN.NGAYNOP)
	from BIENSOAN
	where MAGV = @y and MAGT = @X
	return @ans
end 
print dbo.F2 ('GT001', 'ACT02')
Câu 4a) (2 điểm)
Viết thủ tục P2 có tham số đầu vào là mã số GV (MAGV). Thủ tục cho phép in ra: Tên GV, Tên giáo trình, Ngày bắt đầu, Ngày nộp, Tổng số ngày (bằng cách gọi hàm F2 ở trên). Nếu mã GV không truyền vào thì in tất cả các GV cùng giáo trình tương ứng.
create proc P2 @magv char(5) as 
	if @magv is null 
	begin 
		select TENGV, TENGT, NGAYBD, NGAYNOP, dbo.F2(GIAOTRINH.MAGT,GIANGVIEN.MAGV) as TONG
		from GIANGVIEN, BIENSOAN, GIAOTRINH 
		where GIANGVIEN.MAGV = BIENSOAN.MAGV and GIAOTRINH.MAGT = BIENSOAN.MAGT
	end 
	else 
	begin
		select TENGV, TENGT, NGAYBD, NGAYNOP, dbo.F2(GIAOTRINH.MAGT,GIANGVIEN.MAGV) as [Tong]
		from GIANGVIEN, BIENSOAN, GIAOTRINH
		where BIENSOAN.MAGV = GIANGVIEN.MAGV and GIAOTRINH.MAGT = BIENSOAN.MAGT and GIANGVIEN.MAGV = @magv
	end
exec P2 'KVH01'
Câu 5) (2 điểm)
Mỗi lần biên soạn, mỗi cuốn giáo trình không cho phép hơn 2 GV cùng tham gia viết. Hãy xây dựng trigger có tên T2 đảm bảo ràng buộc này.
create trigger T2 on BIENSOAN
for insert, update 
as 
	declare @x int = 0, @magt char(5) 
	select @magt = MAGT
	from inserted
	group by MAGT
	select @x = count(MAGV)
	from BIENSOAN
	where MAGT = @magt
	group by MAGT
	if (@x > 2)
	begin 
		print ('Mot giao trinh khong duoc qua 2 giao vien bien soan')
		rollback tran
	end 

drop trigger T2

insert into BIENSOAN values ('ACT02','GT002',3,'15/10/2015','1/1/2016')


select * from BIENSOAN


