/*

Cleaning Data in SQL Queries

*/
-----------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT *
from PortfolioProject..NashvilleHousing

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
    LTRIM(RTRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1))) AS PropertySplitAddress,
    'Nashville' AS PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing;



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = LTRIM(RTRIM(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)))



ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = 'Nashville'




select *
FROM PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


SELECT
    REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1)) AS [OwnerSplitaddress],
    REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2)) AS [OwnerSplitCity],
    REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3)) AS [OwnerSplitState]
FROM PortfolioProject.dbo.NashvilleHousing;



ALTER TABLE NashvilleHousing
Add OwnerSplitaddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 1))


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 2))


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = REVERSE(PARSENAME(REPLACE(REVERSE(OwnerAddress), ',', '.'), 3))



Select *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

--Method 1:

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing


--Method 2:
--  We group the rows based on the specified columns.
--  The COUNT(*) tells us how many repeated rows there are for each combination of ParcelID, PropertyAddress, SaleDate, and LegalReference.

SELECT ParcelID, PropertyAddress, SaleDate, LegalReference, COUNT(*) AS occurrence
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY ParcelID, PropertyAddress, SaleDate, LegalReference
HAVING COUNT(*) > 1;


--In this query:
--  We create a Common Table Expression (CTE) that assigns a row number to each row within each group of duplicates.
--  The PARTITION BY clause ensures that the row numbers reset for each unique combination of columns.
--  The DELETE statement removes rows where the row number is greater than 1 (keeping only the first occurrence).

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference ORDER BY (SELECT NULL)) AS RowNum
    FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM CTE WHERE RowNum > 1;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

