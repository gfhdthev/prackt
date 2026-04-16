create database SHOP_ghwt40
use SHOP_ghwt40



create table Goods(
	id int identity(1,1) primary key,
	[name] int,
	[weight] float,
	terminate_date date,
	be bit
	)

create table Goods_list(
	id int identity(1,1) primary key,
	goods int,
	[count] int,
	[status] nvarchar(10) --что не так
	constraint FK_1 foreign key (goods) references Goods(id)
	)

create table Goods_name(
	id int identity(1,1) primary key,
	[name] nvarchar(25),
	constraint FK_3 foreign key (id) references Goods([name])
	)

create table Storage(
	id int identity(1,1) primary key,
	goods_list int,
	available bit,
	constraint FK_2 foreign key (goods_list) references Goods_list(id)
	)

create table LOGS(
	ID int identity(1,1) primary key,
	[TABLE] nvarchar(15),
	OP_TYPE nvarchar(6),
	[Datetime] datetime
	)

create trigger log_trigger_Goods
	on Goods 
	after insert, update, delete
	as
	begin
		declare @op_type_Goods nvarchar(6) --значение столбца с операцией
		begin
			if exists(select * from inserted) and exists(select * from deleted)
				begin
					set @op_type_Goods = 'update'
				end
			else
				begin
					if exists(select * from deleted)
						set @op_type_Goods = 'delete'
					else
						begin
							set @op_type_Goods = 'insert'
						end
				end
			insert into LOGS values ('Goods', @op_type_Goods, getdate())
		end
	end

go create trigger log_trigger_Goods_list
	on Goods_list 
	after insert, update, delete
	as
		declare @op_type_Goods_list nvarchar(6) --значение столбца с операцией
		if exists(select * from inserted) and exists(select * from deleted)
			set @op_type_Goods_list = 'update'
		else if exists(select * from deleted)
			set @op_type_Goods_list = 'delete'
		else
			set @op_type_Goods_list = 'insert'
		insert into LOGS values ('Goods_list', @op_type_Goods_list, getdate())

create trigger log_trigger_Storage
	on Storage 
	after insert, update, delete
	as
		declare @op_type_Storage nvarchar(6) --значение столбца с операцией
		if exists(select * from inserted) and exists(select * from deleted)
			set @op_type_Storage = 'update'
		else if exists(select * from deleted)
			set @op_type_Storage = 'delete'
		else
			set @op_type_Storage = 'insert'
		insert into LOGS values ('Storage', @op_type_Storage, getdate())

create procedure insert_Goods
	@name nvarchar(25),
	@weight float,
	@terminate_date date
	as
	begin
		insert into Goods values (@name, @weight, @terminate_date)
	end

create trigger insert_Goods_list
	on Goods
	after insert
	as	
		declare @good_id nvarchar(25)
		set @good_id = (select id from inserted) --получаем id добавленного товара 
		declare @eaten bit
		if (select terminate_date from inserted) >= getdate()
			set @eaten = 1 --если срок годности еще не провшел
		else
			set @eaten = 0
		if exists(select top 1 * from Goods_list where goods = @good_id)
			update Goods_list
				set [count] += 1, [status] = @eaten
