#import <libactivator/libactivator.h>

/////////////ACTIVATOR CODE

#define LASendEventWithName(eventName) [LASharedActivator sendEventToListener:[LAEvent eventWithName:eventName mode:[LASharedActivator currentEventMode]]]
static NSString *kCellularChanged_eventName = @"CellularChanged";
static NSString *kCellularDisconnected_eventName = @"CellularDisconnected";
static NSString *kCellularConnected_eventName = @"CellularConnected";


@interface CellularChangedDataSource : NSObject <LAEventDataSource> {}
+ (id)sharedInstance;
@end

@implementation CellularChangedDataSource
+ (id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	return sharedInstance;
}

+ (void)load {
	[self sharedInstance];
}

- (id)init {
	if ((self = [super init])) {
		[LASharedActivator registerEventDataSource:self forEventName:kCellularChanged_eventName];
		[LASharedActivator registerEventDataSource:self forEventName:kCellularDisconnected_eventName];
		[LASharedActivator registerEventDataSource:self forEventName:kCellularConnected_eventName];
	}
	return self;
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	if([eventName isEqualToString:kCellularChanged_eventName]){
		return @"Cellular data type changed";
	}else if([eventName isEqualToString:kCellularDisconnected_eventName]){
		return @"Cellular data disconnected";
	}else{
		return @"Cellular data connected";
	}
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
	return @"Network Status";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	if([eventName isEqualToString:kCellularChanged_eventName]){
		return @"Triggers when Cellular data type connection has changed";
	}else if([eventName isEqualToString:kCellularDisconnected_eventName]){
		return @"Triggers when Cellular data has disconnected";
	}else{
		return @"Triggers when Cellular data has connected";
	}

}

- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:kCellularChanged_eventName];
	[LASharedActivator unregisterEventDataSourceWithEventName:kCellularDisconnected_eventName];
	[LASharedActivator unregisterEventDataSourceWithEventName:kCellularConnected_eventName];
	[super dealloc];
}
@end



/////////////MY CODE

/*
6 = 4G
5 = 3G


*/
static int savedint;

%hook SBTelephonyManager
-(SBTelephonyManager *)init{
	SBTelephonyManager *origself = %orig;
	int tempint = MSHookIvar<int>(origself, "_modemDataConnectionType");
	savedint = tempint;
	return origself;
}

-(int)_updateModemDataConnectionTypeWithCTInfo:(id)arg1{
	int toreturn = %orig(arg1);
	if(toreturn != savedint){
		if(toreturn == 0){
			LASendEventWithName(kCellularDisconnected_eventName);
		}else if(savedint == 0){
			LASendEventWithName(kCellularConnected_eventName);
		}
		savedint = toreturn;
		LASendEventWithName(kCellularChanged_eventName);
	}
	return toreturn;
}
%end



%ctor {
	@autoreleasepool {
		%init;
	};
}