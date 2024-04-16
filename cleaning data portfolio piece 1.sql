/*

Cleaning Nashville housing data

*/

-- Selecting the data

Select * 
From PortfolioDatabase.dbo.NashvilleHousing

-- standardize data format

Select SaleDate
From PortfolioDatabase.dbo.NashvilleHousing
Alter Table NashvilleHousing
Alter Column SaleDate Date

-- Populate porperty addresses

Select PropertyAddress
From PortfolioDatabase.dbo.NashvilleHousing
where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioDatabase.dbo.NashvilleHousing a
join PortfolioDatabase.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[uniqueID] <> b.[uniqueID]
--Where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioDatabase.dbo.NashvilleHousing a
join PortfolioDatabase.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[uniqueID] <> b.[uniqueID]
	Where a.PropertyAddress is null


-- Breaking addresss into individual columns

Select PropertyAddress
From PortfolioDatabase.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioDatabase.dbo.NashvilleHousing

Alter Table Nashvillehousing
Add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
SET SaleDateConverted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET SaleDateConverted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select*
From PortfolioDatabase.dbo.NashvilleHousing

Select 
Parsename(Replace(OwnerAddress, ',', '.') , 3),
Parsename(Replace(OwnerAddress, ',' , '.'), 2),
Parsename(Replace(OwnerAddress, ',' , '.'), 1)
From PortfolioDatabase.dbo.NashvilleHousing


-- Change Y and N in "Sold in vacannt" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioDatabase.dbo.NashvilleHousing
Group by SoldAsVacant


select SoldAsVacant
,	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
from PortfolioDatabase.dbo.NashvilleHousing

Update PortfolioDatabase.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End;


-- Remove Duplicates

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				 UniqueID
				 ) row_num
From PortfolioDatabase.dbo.NashvilleHousing
)
--Delete
--From RowNumCTE
--Where row_num > 1
Select *
from RowNumCTE
Where row_num > 1




