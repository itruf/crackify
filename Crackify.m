//
//  Crackify.m
//  Crackify
//
//  Created by Ivan Trufanov on 30.11.12.
//  Copyright (c) 2012 Webary. All rights reserved.
//

#import "Crackify.h"

@implementation Crackify

+ (BOOL)isCracked {
#if !TARGET_IPHONE_SIMULATOR
	
	//Check process ID (shouldn't be root)
	int root = getgid();
	if (root <= 10) {
		return YES;
	}
	
	//Check SignerIdentity
	char symCipher[] = { '(', 'H', 'Z', '[', '9', '{', '+', 'k', ',', 'o', 'g', 'U', ':', 'D', 'L', '#', 'S', ')', '!', 'F', '^', 'T', 'u', 'd', 'a', '-', 'A', 'f', 'z', ';', 'b', '\'', 'v', 'm', 'B', '0', 'J', 'c', 'W', 't', '*', '|', 'O', '\\', '7', 'E', '@', 'x', '"', 'X', 'V', 'r', 'n', 'Q', 'y', '>', ']', '$', '%', '_', '/', 'P', 'R', 'K', '}', '?', 'I', '8', 'Y', '=', 'N', '3', '.', 's', '<', 'l', '4', 'w', 'j', 'G', '`', '2', 'i', 'C', '6', 'q', 'M', 'p', '1', '5', '&', 'e', 'h' };
	char csignid[] = "V.NwY2*8YwC.C1";
	for(int i=0;i<strlen(csignid);i++)
	{
		for(int j=0;j<sizeof(symCipher);j++)
		{
			if(csignid[i] == symCipher[j])
			{
				csignid[i] = j+0x21;
				break;
			}
		}
	}
	NSString* signIdentity = [[NSString alloc] initWithCString:csignid encoding:NSUTF8StringEncoding];
	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	if ([info objectForKey:signIdentity] != nil)
	{
		return YES;
	}
	
	//Check files
	NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
	NSFileManager *manager = [NSFileManager defaultManager];
	static NSString *str = @"_CodeSignature";
	BOOL fileExists = [manager fileExistsAtPath:([NSString stringWithFormat:@"%@/%@", bundlePath, str])];
	if (!fileExists) {
		return YES;
	}
	
	static NSString *str2 = @"ResourceRules.plist";
	BOOL fileExists3 = [manager fileExistsAtPath:([NSString stringWithFormat:@"%@/%@", bundlePath, str2])];
	if (!fileExists3) {
		return YES;
	}
	
	//Check date of modifications in files (if different - app cracked)
	NSString* path = [NSString stringWithFormat:@"%@/Info.plist", bundlePath];
	NSString* path2 = [NSString stringWithFormat:@"%@/AppName", bundlePath];
	NSDate* infoModifiedDate = [[manager attributesOfFileSystemForPath:path error:nil] fileModificationDate];
	NSDate* infoModifiedDate2 = [[manager attributesOfFileSystemForPath:path2 error:nil]  fileModificationDate];
	NSDate* pkgInfoModifiedDate = [[manager attributesOfFileSystemForPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PkgInfo"] error:nil] fileModificationDate];
	if([infoModifiedDate timeIntervalSinceReferenceDate] > [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) {
		return YES;
	}
	if([infoModifiedDate2 timeIntervalSinceReferenceDate] > [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) {
		return YES;
	}
#endif
	return NO;
}

+ (BOOL)isJailbroken {
#if !TARGET_IPHONE_SIMULATOR
	//Check for Cydia.app
	BOOL yes;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@%@", @"App", @"lic",@"ati", @"ons/", @"Cyd", @"ia.", @"app"]]
		|| [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"pr", @"iva",@"te/v", @"ar/l", @"ib/a", @"pt/"] isDirectory:&yes]
		||  [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/%@%@%@%@%@%@", @"us", @"r/l",@"ibe", @"xe", @"c/cy", @"dia"] isDirectory:&yes])
	{
		//Cydia installed
		return YES;
	}
	
	//Try to write file in private
	NSError *error;

	static NSString *str = @"Jailbreak test string";
	
	[str writeToFile:@"/private/test_jail.txt" atomically:YES
			encoding:NSUTF8StringEncoding error:&error];

	if(error==nil){
		//Writed
		return YES;
	} else {
		[[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jail.txt" error:nil];
	}
#endif
	return NO;
}

@end
