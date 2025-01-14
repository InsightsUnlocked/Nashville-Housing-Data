SELECT * FROM Nashville_Housing_db..NashvilleHousing;

--Changing the date format--
SELECT saledate,CONVERT(DATE,saledate) FROM Nashville_Housing_db..NashvilleHousing;

ALTER TABLE Nashville_Housing_db..NashvilleHousing
ADD SaleDateConverted  DATE

UPDATE Nashville_Housing_db..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,saledate);

--Populating property address where there is NUll--
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_db..NashvilleHousing a
JOIN Nashville_Housing_db..NashvilleHousing b ON
a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing_db..NashvilleHousing a
JOIN Nashville_Housing_db..NashvilleHousing b ON
a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Updating the address and splitting it by the city--
SELECT propertyAddress, 
SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress)-1) as Address,
SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress)) as City
FROM Nashville_Housing_db..NashvilleHousing

ALTER TABLE Nashville_Housing_db..NashvilleHousing
ADD propertySplitAddress NVARCHAR(255)

ALTER TABLE Nashville_Housing_db..NashvilleHousing
ADD propertyCity NVARCHAR(255)

UPDATE Nashville_Housing_db..NashvilleHousing
SET propertySplitAddress = SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress)-1)

UPDATE Nashville_Housing_db..NashvilleHousing
SET propertyCity = SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress))

SELECT * FROM Nashville_Housing_db..NashvilleHousing

--Doing the same for OwnerAddress column but with using ParseName function--

SELECT PARSENAME(REPLACE(ownerAddress,',','.'),3),
PARSENAME(REPLACE(ownerAddress,',','.'),2),
PARSENAME(REPLACE(ownerAddress,',','.'),1)
FROM Nashville_Housing_db..NashvilleHousing

ALTER TABLE Nashville_Housing_db..NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255)

UPDATE Nashville_Housing_db..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(ownerAddress,',','.'),1)

ALTER TABLE Nashville_Housing_db..NashvilleHousing
ADD OwnerCity NVARCHAR(255)

UPDATE Nashville_Housing_db..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(ownerAddress,',','.'),2)

ALTER TABLE Nashville_Housing_db..NashvilleHousing
ADD OwnerState NVARCHAR(255)

UPDATE Nashville_Housing_db..NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(ownerAddress,',','.'),3)

SELECT * FROM Nashville_Housing_db..NashvilleHousing


--Changing 'Y' and 'N' to yes and no--

SELECT Soldasvacant,
CASE WHEN Soldasvacant = 'Y'
     THEN 'Yes'
	 WHEN Soldasvacant = 'N'
	 THEN 'No'
	 ELSE Soldasvacant
	 END
FROM Nashville_Housing_db..NashvilleHousing

UPDATE Nashville_Housing_db..NashvilleHousing
SET soldasvacant = CASE WHEN Soldasvacant = 'Y'
     THEN 'Yes'
	 WHEN Soldasvacant = 'N'
	 THEN 'No'
	 ELSE Soldasvacant
	 END

SELECT DISTINCT(soldasvacant) FROM  Nashville_Housing_db..NashvilleHousing


--DELETING THE DUPLICATE VALUES--
WITH ROWNUM AS(
SELECT * , ROW_NUMBER() OVER(
                        PARTITION BY parcelID,
						             propertyaddress,
						             Saledate,
									 Saleprice,
									 legalreference
									 ORDER BY UniqueID
									 )row_num
FROM Nashville_Housing_db..NashvilleHousing
)

DELETE  FROM ROWNUM
WHERE row_num=2

--DELETING UNUSED COLUMNS--
SELECT * FROM Nashville_Housing_db..NashvilleHousing

ALTER TABLE Nashville_Housing_db..NashvilleHousing
DROP COLUMN propertyaddress,saledate,owneraddress,taxdistrict