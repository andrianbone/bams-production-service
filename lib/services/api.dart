// Live
// const uri = 'http://bams.mncgroup.com/';

// Dev
const uri = 'http://bamsdev.mncgroup.com:8090/';
// local
// const uri = 'http://10.21.238.81/bams/';

// Config
const packageID = '25'; // Production Service

const uriLocationList = '${uri}json/apitobe/location_list?package=$packageID';
// const uriLocationList = '${uri}json/apitobe/location_list?remark=ALL';

//Login
const uriLogin = '${uri}json/apitobe/login';

// Item Qty List
const uriQtyLocationList = '${uri}json/apitobe/item_qty_list';

// Booking Order Production Service
const uriBoList = '${uri}json/api/booking_order_list';
const uriBoDetail = '${uri}json/apitobe/booking_order_detail/';
const uriTrxCheckout = '${uri}json/apitobe/transaction_checkout_ps';

// CheckIn Production Service
const uriCheckInList = '${uri}json/api/checkin_list';
const uriCheckinDetail = '${uri}json/apitobe/checkin_detail_ps/';
const uriTrxCheckIn = '${uri}json/apitobe/transaction_checkin_ps';

// const packageID = '10'; // Lighting

// Booking Order
// const uriBoList = '${uri}json/audioapi/booking_order_list';
// const uriBoDetail = '${uri}json/audioapi/booking_order_detail/';
// const uriTrxCheckout = '${uri}json/audioapi/transaction_checkout';

// CheckIn
// const uriCheckInList = '${uri}json/audioapi/checkin_list';
// const uriCheckinDetail = '${uri}json/audioapi/checkin_detail/';
// const uriTrxCheckIn = '${uri}json/audioapi/transaction_checkin';