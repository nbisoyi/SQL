/*

Data Cleaning in SQL

*/

Select * 
From portfolio.dbo.Nashville_housing;

----------------------------------------------------------------
---Standardize the Date Format

Select SaleDate , CONVERT(Date, SaleDate)AS SaleDateConverted
From  portfolio.dbo.Nashville_housing




-----------------------------------------------------------------
---Populate Property Address Data(if there are any null value in Property address we will populate them with address)

Select  *
From portfolio.dbo.Nashville_housing
WHERE PropertyAddress IS NULL
Order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio.dbo.Nashville_housing a
JOIN  portfolio.dbo.Nashville_housing b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
From portfolio.dbo.Nashville_housing a
JOIN  portfolio.dbo.Nashville_housing b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

Select * 
From portfolio.dbo.Nashville_housing
where PropertyAddress is not null


-----------------------------------------------------------------
--Breaking out Address into Individual Columns(Addresss,City, State)

SELECT PropertyAddress
From portfolio.dbo.Nashville_housing
---Order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) As Address 
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,LEN(PropertyAddress)) As Address 
From portfolio.dbo.Nashville_housing

ALTER TABLE portfolio.dbo.Nashville_housing
ADD PropertySplitAddress NVarchar(255);

Update portfolio.dbo.Nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE portfolio.dbo.Nashville_housing
ADD PropertySplitCity Nvarchar(255);

Update portfolio.dbo.Nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select * 
From portfolio.dbo.Nashville_housing

/*Simpler way to split the address using PARSENAME*/

Select OwnerAddress
From portfolio.dbo.Nashville_housing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From portfolio.dbo.Nashville_housing

ALTER TABLE portfolio.dbo.Nashville_housing
ADD OwnerSplitAddress NVarchar(255);

Update portfolio.dbo.Nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE portfolio.dbo.Nashville_housing
ADD OwnerSplitCity NVarchar(255);

Update portfolio.dbo.Nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE portfolio.dbo.Nashville_housing
ADD OwnerSplitState NVarchar(255);


Update portfolio.dbo.Nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
From portfolio.dbo.Nashville_housing

------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
From  portfolio.dbo.Nashville_housing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
 From  portfolio.dbo.Nashville_housing

 Update portfolio.dbo.Nashville_housing
 SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


SELECT *
From  portfolio.dbo.Nashville_housing


---------------------------------------------------
--Remove Duplicates

Select *
From portfolio.dbo.Nashville_housing

--Select *, ROW_NUMBER()OVER(
--	  PARTITION BY ParcelID,
--	               PropertyAddress,
--	               SalePrice,
--	               SaleDate,
--	               LegalReference
--	              ORDER BY 
--	                    UniqueID
--		                 )row_num

--From portfolio.dbo.Nashville_housing
----ORDER BY ParcelID

/*Temporary table RownumCTE */

WITH RowNumCTE AS(
 SELECT *,
        ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					        UniqueID
					      ) row_num
From portfolio.dbo.Nashville_housing
)
Select  *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

------------------------------
--Deletinh evrything those are duplicates

WITH RowNumCTE AS(
 SELECT *,
        ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					        UniqueID
					      ) row_num
From portfolio.dbo.Nashville_housing
                  )

DELETE 
From RowNumCTE
Where row_num >1

/* Check if there are any duplicates after deleting */

WITH RowNumCTE AS(
 SELECT *,
        ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		             PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
					        UniqueID
					      ) row_num
From portfolio.dbo.Nashville_housing
)
Select  *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

SELECT *
From portfolio.dbo.Nashville_housing

-----------------------------------------------------------------------
--Delete Unused Columns

SELECT *
From portfolio.dbo.Nashville_housing


ALTER TABLE portfolio.dbo.Nashville_housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress, SaleDate









