/* Cleaning data using SQL Queries
*/

SELECT * FROM PortifolioProject..NashvilleHousing

/* Update SaleDate format
*/

/* Add new column called SaleDateConverted
*/
ALTER TABLE PortifolioProject..NashvilleHousing
ADD SaleDateConverted date

/* Update values in SaleDateConverted using CONVERT */
UPDATE PortifolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)



/* Populate property address null data using ISNULL. 

Columns with the same ParcelID have the same PropertyAddress
*/
SELECT * FROM PortifolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortifolioProject..NashvilleHousing a
JOIN PortifolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortifolioProject..NashvilleHousing a
JOIN PortifolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

/*
Splitting Address into individual columns using SUBSTRING + CHARINDEX: Address, City, State
*/

SELECT PropertyAddress FROM PortifolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortifolioProject..NashvilleHousing


ALTER TABLE PortifolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE PortifolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortifolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortifolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity  FROM PortifolioProject..NashvilleHousing

/*
Splitting Address into individual columns using PARSENAME + REPLACE: Address, City, State
*/

SELECT OwnerAddress FROM PortifolioProject..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortifolioProject..NashvilleHousing

ALTER TABLE PortifolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE PortifolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortifolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortifolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortifolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE PortifolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState FROM PortifolioProject..NashvilleHousing


/*
Change Y and N to Yes and No in 'SoldAsVacant' field using CASE WHEN
*/

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortifolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END
FROM PortifolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'NO'
ELSE SoldAsVacant
END

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortifolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

/*
Remove Duplicates using ROW_NUMBER, CTEs and PARTITION BY (WINDOWS FUNCTION)
*/

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference
	ORDER BY UniqueID) AS row_num

FROM PortifolioProject..NashvilleHousing
)
DELETE FROM RowNumCTE 
WHERE row_num > 1


/*
Remove unused Columns for viewing purposes. Best practicies is to keep the raw data after querying in SQL.
*/

SELECT * FROM PortifolioProject..NashvilleHousing

ALTER TABLE PortifolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
