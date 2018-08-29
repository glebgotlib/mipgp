//
//  NSObject+MIgpgCon.h
//  GPG Memory
//
//  Created by Sergey Eropunov on 11/23/16.
//  Copyright © 2016 Sergey Eropunov. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "migpg.h"

@interface MIPGPCon : NSObject
{
    int result;
}

//init class controll
+ (MIPGPCon*)instance;


- (NSMutableArray *) privateKeyList;
- (NSMutableArray *) publicKeyList;

- (NSString *)generateKey:(int) size name:(NSString *)_name comment:(NSString *)_comment email:(NSString *)_email password:(NSString *)_password;

- (void) passwordIsValid:(NSString *)password fpr:(NSString *)_fpr result:(void (^)(BOOL result)) block;

- (BOOL) importKey:(NSString *)key;
- (NSMutableDictionary *) importKetReturnInfo:(NSString *)key;

- (NSString *)exportKey:(NSString *)fpr;
- (NSString *)exportPrivateKey:(NSString *)fpr;

- (void)enacryptMessage:(NSString *)message fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block;
- (void)decryptMessage:(NSString *)message password:(NSString *)_password result:(void (^)(NSString *result)) block;
- (void)decryptData:(NSData *)data password:(NSString *)_password result:(void (^)(NSString *result)) block;

- (void)enacryptMessageNoHeader:(NSString *)message fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block;
- (void)decryptMessageNoHeader:(NSString *)message password:(NSString *)_password result:(void (^)(NSString *result)) block;

- (void)enacryptNoArmorMessage:(NSString *)message fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block;
- (void)decryptNoArmorMessage:(NSString *)message password:(NSString *)_password result:(void (^)(NSString *result)) block;

- (void)enacryptFile:(NSString *)file fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block;
- (void)decryptFile:(NSString *)file password:(NSString *)_password result:(void (^)(NSString *result)) block;


- (BOOL)deleteKey:(NSString *)fpr secret:(int)secret;
- (NSMutableArray *) serverKeyList:(NSString *)_server user:(NSString *)_user;

- (BOOL)sendKeyToServer:(NSString *)_fpr server:(NSString *)_server;

- (NSMutableArray *)importKeyForServer:(NSString *)_server user:(NSString *)_user;
- (NSMutableArray *)importKeyForServer:(NSString *)_server fpr:(NSString *)_fpr;

- (NSMutableArray *)importKeyForLDAP_HLRServer:(NSString *)_server user:(NSString *)_user;

- (BOOL) changePassword:(NSString *)_oldPassword newPassword:(NSString *)password fpr:(NSString *)privatefpr;


- (void) deleteAllKayes;

@end
