# Menu Module API Documentation

## Overview
The Menu module provides comprehensive REST APIs for managing restaurant menu items with features including pagination, sorting, filtering, search, and favorites.

## Endpoints

### Public Endpoints (No Authentication Required)

#### 1. Get All Menu Items (with Pagination & Filtering)
```
GET /menu-items
```
**Query Parameters:**
- `page` (number, default: 1) - Page number
- `limit` (number, default: 10, max: 100) - Items per page
- `sortBy` (string, default: 'name') - Sort field (name, price, status)
- `sortOrder` ('asc' | 'desc', default: 'asc') - Sort direction
- `search` (string) - Search in name and description
- `category` (string) - Filter by category
- `restaurantId` (string) - Filter by restaurant
- `minPrice` (number) - Minimum price filter
- `maxPrice` (number) - Maximum price filter
- `status` ('AVAILABLE' | 'UNAVAILABLE') - Filter by status

**Response:**
```json
{
  "data": [
    {
      "food_id": "FD00000000000001",
      "restaurant_id": "RT00000000000001",
      "name": "Burger",
      "description": "Delicious beef burger",
      "price": 12.99,
      "status": "AVAILABLE",
      "categories": ["Fast Food", "Main Course"],
      "restaurant": {
        "restaurant_id": "RT00000000000001",
        "name": "Burger King",
        "address_details": "123 Main St",
        "phone": "1234567890",
        "status": "OPEN"
      },
      "is_favorite": false
    }
  ],
  "meta": {
    "total": 50,
    "page": 1,
    "limit": 10,
    "totalPages": 5
  }
}
```

#### 2. Get Restaurant Menu
```
GET /restaurants/:restaurantId/menu
```

#### 3. Get Menu Item by ID
```
GET /menu-items/:restaurantId/:menuItemId
```

#### 4. Get All Categories
```
GET /categories
```
**Response:**
```json
[
  {
    "name": "Fast Food",
    "itemCount": 25
  }
]
```

#### 5. Get Menu Items by Category
```
GET /menu-items/category/:category
```

#### 6. Search Menu Items
```
GET /menu-items/search?query=burger
```

### Protected Endpoints (Authentication Required)

#### 7. Create Menu Item (Restaurant Owner Only)
```
POST /menu-items
Authorization: Bearer <token>
```
**Request Body:**
```json
{
  "name": "Burger",
  "description": "Delicious beef burger",
  "price": 12.99,
  "restaurant_id": "RT00000000000001",
  "status": "AVAILABLE",
  "categories": ["Fast Food", "Main Course"]
}
```

#### 8. Update Menu Item (Restaurant Owner Only)
```
PUT /menu-items/:restaurantId/:menuItemId
Authorization: Bearer <token>
```
**Request Body:**
```json
{
  "name": "Updated Burger",
  "price": 13.99,
  "status": "UNAVAILABLE",
  "categories": ["Fast Food"]
}
```

#### 9. Delete Menu Item (Restaurant Owner Only)
```
DELETE /menu-items/:restaurantId/:menuItemId
Authorization: Bearer <token>
```

#### 10. Toggle Favorite Menu Item
```
POST /menu-items/:menuItemId/favorite
Authorization: Bearer <token>
```
**Request Body:**
```json
{
  "restaurant_id": "RT00000000000001"
}
```

#### 11. Get Favorite Menu Items
```
GET /menu-items/favorites
Authorization: Bearer <token>
```

## Features

### 1. Pagination
All list endpoints support pagination with `page` and `limit` parameters.

### 2. Sorting
Sortable by:
- Name (alphabetical)
- Price (numerical)
- Status (alphabetical)

### 3. Filtering
Filter by:
- Category
- Restaurant
- Price range (min/max)
- Status (AVAILABLE/UNAVAILABLE)
- Search query (name and description)

### 4. Authorization
- **Public access**: Browse menu items, search, view categories
- **Customer access**: Mark favorites, view own favorites
- **Restaurant Owner access**: Create, update, delete menu items for owned restaurants

### 5. Validation
All inputs are validated using class-validator:
- Required fields enforcement
- Type checking
- String length limits
- Number ranges
- Enum validation

## Database Schema

### Tables Used
- `menu_item` - Menu item records
- `category` - Category definitions
- `category_items` - Menu item to category relationships
- `menu_item_favourite` - User favorites
- `restaurant` - Restaurant information

### Composite Keys
- Menu items: `(restaurant_id, food_id)`
- Favorites: `(customer_id, restaurant_id, menu_item_id)`

## Error Handling

- `400 Bad Request` - Invalid input data
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found

## Notes

1. Menu item IDs are auto-generated using the sequence `dbo.pk_sequence`
2. The `is_favorite` field is dynamically computed based on the authenticated user
3. Public endpoints can optionally include user context to show favorites
4. Category assignments are managed through a junction table
5. All monetary values use Decimal type for precision
