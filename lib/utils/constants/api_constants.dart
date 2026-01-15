const String API_BASE_URL = 'http://81.3.182.146';
const String ORDER_LOCATION_URL = '${API_BASE_URL}/flight/orderlocation';
const String PRODUCTS_URL = '${API_BASE_URL}/order/getproducts';
const String ORDERS_URL = '${API_BASE_URL}/order/getorders';
const String PLACE_ORDER_URL = '${API_BASE_URL}/order/placeorder';
const String CREATE_PRODUCT_URL = '${API_BASE_URL}/order/creatproduct';
const String ORDER_STATUS_URL = '${API_BASE_URL}/order/sseorders';
const String UPDATE_ORDER_STATUS_URL = '${API_BASE_URL}/order/updatestatus';
const String DELETE_PRODUCT_URL = '${API_BASE_URL}/order/deleteproduct';
const String DELETE_ORDER_URL = '${API_BASE_URL}/order/deleteorder';

// WebSocket URLs
const String WS_BASE_URL = 'ws://81.3.182.146';
const String WS_DRONE_STATUS_URL = '${WS_BASE_URL}/ws/status';
const String WS_DRONEBOX_STATUS_URL = '${WS_BASE_URL}/ws/statusdb';