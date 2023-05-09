--Cleaning Data in SQL

Select *
From dbo.NashHousing

--Standardize Date Format

Select SaleDate2, Convert(Date,SaleDate)
From dbo.NashHousing

Alter Table NashHousing
Add SaleDate2 Date;

Update NashHousing
Set SaleDate2 = Convert(Date,SaleDate)

--Populate Property Address data

Select *
From dbo.NashHousing
--Where PropertyAddress is null
Order by ParcelID


Select 
a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashHousing a
Join NashHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.NashHousing a
Join NashHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From dbo.NashHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
Substring(PropertyAddress,1, Charindex(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From dbo.NashHousing

--Creating 2 new columns
Alter Table NashHousing
Add PropertySplitAddress Nvarchar(255);

Update NashHousing
Set PropertySplitAddress = Substring(PropertyAddress,1, Charindex(',',PropertyAddress)-1)

Alter Table NashHousing
Add PropertySplitCity Nvarchar(255);

Update NashHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',',PropertyAddress)+1, LEN(PropertyAddress))



--Owner Address Splitting into Address, city and State

Select
Parsename(Replace(OwnerAddress, ',','.'),3)
,Parsename(Replace(OwnerAddress, ',','.'),2)
,Parsename(Replace(OwnerAddress, ',','.'),1)
From dbo.NashHousing


Alter Table NashHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'),3)

Alter Table NashHousing
Add OwnerSplitCity Nvarchar(255);

Update NashHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'),2)


Alter Table NashHousing
Add OwnerSplitState Nvarchar(255);

Update NashHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'),1)


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant)
From dbo.NashHousing

Select 
SoldAsVacant,
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From dbo.NashHousing

Update NashHousing
Set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End


--Remove Duplicates
With RowNumCTE as (
Select*,
	ROW_NUMBER() Over (
	Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	Order by UniqueID) Row_Num
From dbo.NashHousing
--Order by ParcelID 
)
Select *
From RowNumCTE
Where Row_Num >1


--Delete Unused Columns

Select *
From dbo.NashHousing

Alter Table dbo.NashHousing
Drop column OwnerAddress,TaxDistrict,PropertyAddress

Alter Table dbo.NashHousing
Drop column SaleDate