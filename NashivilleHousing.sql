Create TABLE NashivilleHousing (UniqueID integer, ParcelID text, LandUse text, PropertyAddress text, SaleDate date, SalePrice bigint, LegalReference text, SoldAsVacant text, OwnerName	text, OwnerAddress text, Acreage numeric, TaxDistrict text,	LandValue bigint, BuildingValue bigint,	TotalValue bigint, YearBuilt integer, Bedrooms integer, FullBath integer, HalfBath integer);
copy NashivilleHousing from 'D:\Projects\NashivilleHousing\Nashville Housing Data for Data Cleaning.csv' with delimiter ';' csv header;
--SET datestyle to dmy;


--Cleaning Data in SQL Queries
select * from NashivilleHousing;

--------------------------------------------------Standartize Date Format

--alter table NashivilleHousing --If you performed an import with datetime
--alter saledate type date

select saledate 
from NashivilleHousing;


-------------------------------------------------Populate Property Adress Data

Select *
from NashivilleHousing
--where propertyaddress is null --Checked cells with a blank address
order by parcelid;


Select n1.Parcelid, n1.PropertyAddress, n2.Parcelid, n2.PropertyAddress, case when n1.PropertyAddress is null then n2.PropertyAddress else n1.PropertyAddress end
from NashivilleHousing n1
join NashivilleHousing n2
on n1.parcelid = n2.parcelid
and n1.uniqueid <> n2.uniqueid
where n1.propertyaddress is null;

with cte as (
Select n1.uniqueid, n1.Parcelid, n1.PropertyAddress as propertyaddresss, n2.Parcelid, n2.PropertyAddress, coalesce(n1.propertyaddress, n2.PropertyAddress)
from NashivilleHousing n1
join NashivilleHousing n2
on n1.parcelid = n2.parcelid
and n1.uniqueid <> n2.uniqueid
where n1.propertyaddress is null
)
update NashivilleHousing
set PropertyAddress = coalesce(cte.propertyaddresss, cte.PropertyAddress)
from cte
where NashivilleHousing.uniqueid = cte.uniqueid


----------------------------------------Breaking out Address into individual columns(Address, City, State)

Select substring(n.propertyaddress from 1 for position(',' in n.propertyaddress) -1) as Address, 
substring(n.propertyaddress from position(',' in n.propertyaddress) +1) as City
from NashivilleHousing n;

alter table NashivilleHousing
add PropetySplitAddress text;

update NashivilleHousing
set PropetySplitAddress = substring(propertyaddress from 1 for position(',' in propertyaddress) -1);

alter table NashivilleHousing
add PropetySplitCity text;

update NashivilleHousing
set PropetySplitCity = substring(propertyaddress from position(',' in propertyaddress) +1);

----------------------------
Select owneraddress,
split_part(owneraddress, ',', 1) as Address,
split_part(owneraddress, ',', 2) as City,
split_part(owneraddress, ',', 3) as State
from NashivilleHousing;

alter table NashivilleHousing
add OwnerSplitAddress text;

update NashivilleHousing
set OwnerSplitAddress = split_part(owneraddress, ',', 1);

alter table NashivilleHousing
add OwnerSplitCity text;

update NashivilleHousing
set OwnerSplitCity = split_part(owneraddress, ',', 2);

alter table NashivilleHousing
add OwnerSplitState text;

update NashivilleHousing
set OwnerSplitState = split_part(owneraddress, ',', 3);




-------------------------------------------------Change Y and N to Yes and No in "Sold as Vacant" field
select distinct soldasvacant, count(soldasvacant)
from NashivilleHousing
group by soldasvacant
order by 2

update NashivilleHousing
set soldasvacant = case 
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end;
	
	
---------------------------------------------------Remove Dublicates

With RowNumberCTE as (
	Select *, Row_number() over(
		Partition By Parcelid, PropertyAddress, saledate, saleprice, legalreference
		order by uniqueid) as row_num
	from NashivilleHousing
) 
Select * from RowNumberCTE where row_num > 1;


Delete from NashivilleHousing where uniqueid not in 
(select max(uniqueid) from NashivilleHousing n
 group by n.Parcelid, n.PropertyAddress, n.saledate, n.saleprice, n.legalreference);
 
 
 ---------------------------------------------------Drop Unused Columns
  
 Alter Table NashivilleHousing
 Drop Column owneraddress,  Drop Column PropertyAddress;
 
 
 
 