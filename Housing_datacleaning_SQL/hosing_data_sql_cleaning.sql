--converting the saledatetable to date table
-- it can be done either by convert cmd or by altering table
select saleDate,CONVERT(Date,SaleDate)
from nvhousing

update nvhousing
set sale_date = CONVERT(Date,saleDate)

select saledate from nvhousing

alter table nvhousing
add sale_date Date;

select *
from nvhousing

alter table nvhousing  drop column saledate

--selecting the null values and replacing the null values with address by doing self join 
select propertyaddress from nvhousing where propertyaddress is null

select a.parcelid,b.parcelid,a.propertyaddress,b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
from nvhousing as a join nvhousing as b on a.parcelId=b.parcelID  and a.uniqueid <> b.uniqueID
where a.propertyaddress is null

--updating the table with new address 
update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from  nvhousing as a join nvhousing as b on a.parcelId=b.parcelID  and a.uniqueid <> b.uniqueID
where a.propertyaddress is null

select *
from nvhousing
--extracting info from Property address colm with the help of substring functon 
select 
SUBSTRING(PropertyAddress,1,charindex(',',Propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as address
from nvhousing

alter table nvhousing add Property_address varchar (255)

update nvhousing
set property_address = (select 
SUBSTRING(PropertyAddress,1,charindex(',',Propertyaddress)-1) as address)
from nvhousing

select * from nvhousing

alter table nvhousing
add city nvarchar(255)

update nvhousing 
set city=(select 
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as address)
from nvhousing


--select SUBSTRING(owneraddress,1,CHARINDEX(',',owneraddress)-1) as address_owner from nvhousing

--select SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,)) as w_acity from nvhousing

alter  table nvhousing
add owner_city nvarchar(255)

update nvhousing
set owner_city=PARSENAME(Replace(ownerAddress,',','.'),2)

alter table nvhousing
add owner_state nvarchar(255)

update nvhousing
set owner_state=parseName(REPLACE(ownerAddress,',','.'),1)

alter table nvhousing 
add owner_address nvarchar(255)

update nvhousing set Owner_Address=PARSENAME(replace(owneraddress,',','.'),3)

select SoldAsVacant
,CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant ='N' then 'No'
	   else SoldAsVacant
	   end
from nvhousing

update nvhousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant ='N' then 'No'
	   else SoldAsVacant
	   end
from nvhousing

select distinct(soldasvacant)
from nvhousing

--Removing duplicate

select *,
   row_number()over(
   partition by parcellID,
                propertyaddress,		
				Saleprice,		
				LegalReference	
				ORDER BY 
				   uniqueID
				   ) row_num
from nvhousing
order by ParcelID

with Rownumcte as (
select *, row_number() over (
         partition by ParcelID,	
		              Propertyaddress,
					  Saleprice,
					  LegalReference
					  order by 
					    uniqueID
						) row_num
From nvhousing)

select *   from rownumcte where row_num>1

alter table nvhousing
drop column owneraddress,Taxdistrict

select * from nvhousing