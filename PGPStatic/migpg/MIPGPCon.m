//
//  NSObject+MIgpgCon.m
//  GPG Memory
//
//  Created by Sergey Eropunov on 11/23/16.
//  Copyright © 2016 Sergey Eropunov. All rights reserved.
//

#import "MIPGPCon.h"
#include <objc/runtime.h>

static MIPGPCon *instance = nil;

@implementation MIPGPCon

+ (MIPGPCon*)instance
{
    if (!instance)
        instance = [[MIPGPCon alloc] init];
    return instance;
}

- (NSString*)_filePath {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        result = mi_init("~/Library/Preferences/.gnupg");
        opt.verbose = 0;
    }
    return self;
}



-(BOOL) importKey:(NSString *)key {
    BOOL returnData = NO;
    // Import
    if (result == 0) {
        mi_imported_t *mm = NULL;
        
        NSData* storage= [key dataUsingEncoding:NSUTF8StringEncoding];
        
        char *imp= (char *)storage.bytes;
        int impl = (int)storage.length;
        
        int rc = mi_import(imp, impl, &mm);
        if (rc == 0) returnData = YES;
        
        mi_import_free(mm);
        mm = NULL;
    }
    return returnData;
}


-(NSMutableDictionary *)importKetReturnInfo:(NSString *)key {
    NSMutableDictionary *obj = [NSMutableDictionary new];
    
    if (result == 0) {
        mi_imported_t *mm = NULL;
        
        NSData* storage= [key dataUsingEncoding:NSUTF8StringEncoding];
        
        char *imp= (char *)storage.bytes;
        int impl = (int)storage.length;
        
        int rc = mi_import(imp, impl, &mm);
        if (rc == 0){
            mi_imported_t *mp = NULL;
             for(; mm; mm = mp) {
                 if (mm != NULL) {
                     [obj setObject:[NSString stringWithFormat:@"%s", mm->short_fpr] forKey:@"id"];
                     [obj setObject:[NSString stringWithFormat:@"%s", mm->info] forKey:@"name"];
                     [obj setObject:[NSString stringWithFormat:@"%s", mm->fpr] forKey:@"fpr"];
                 }
             }
        } else {
            NSLog(@"Error");
        }
        mi_import_free(mm);
        mm = NULL;
    }
    
    return obj;
}

-(NSMutableArray *) privateKeyList {
    NSMutableArray *list = [NSMutableArray new];
    
    list_key_t *keys = NULL;
    int rc = mi_list_keys(&keys, 1);
    
    if (rc == 0) {
        list_key_t *lk = keys;
        for(; lk; lk = lk->next) {
           
            NSMutableDictionary *obj = [NSMutableDictionary new];
            [obj setObject:[NSString stringWithFormat:@"%s", lk->secret?"sec":"pub"] forKey:@"type"];
            [obj setObject:[NSString stringWithFormat:@"%08X%08X", lk->keyid[0], lk->keyid[1]] forKey:@"id"];
            [obj setObject:[NSString stringWithFormat:@"%s", lk->uid.name] forKey:@"name"];
            [obj setObject:[NSString stringWithFormat:@"%s", lk->fpr] forKey:@"fpr"];
            [list addObject:obj];
        }
    }else
        printf("error of get public keys\n");
    
    mi_list_keys_free(keys);
    
    return list;
}

- (NSMutableArray *) publicKeyList {
    NSMutableArray *list = [NSMutableArray new];
    
    list_key_t *keys = NULL;
    int rc = mi_list_keys(&keys, 0);
    
    if (rc == 0) {
        list_key_t *lk = keys;
        for(; lk; lk = lk->next) {
            
            NSMutableDictionary *obj = [NSMutableDictionary new];
            [obj setObject:[NSString stringWithFormat:@"%s", lk->secret?"sec":"pub"] forKey:@"type"];
            [obj setObject:[NSString stringWithFormat:@"%08X%08X", lk->keyid[0], lk->keyid[1]] forKey:@"id"];
            [obj setObject:[NSString stringWithFormat:@"%s", lk->uid.name] forKey:@"name"];
            [obj setObject:[NSString stringWithFormat:@"%s", lk->fpr] forKey:@"fpr"];
            [list addObject:obj];
        }
    }else
        printf("error of get public keys\n");
    
    mi_list_keys_free(keys);
    
    return list;
}


- (NSString *)exportKey:(NSString *)fpr {
    NSString *returnDataString = @"Error";
    // Export
    char *_out = NULL;
    const char *_fpr=[fpr UTF8String];
    
    int len = 0;
    if (!mi_export((char *)_fpr, 0, 1, &_out, &len)) {
        returnDataString = [NSString stringWithFormat:@"%s",_out];
    }
    xfree(_out);
    _out = NULL;
    return returnDataString;
}


- (NSString *)exportPrivateKey:(NSString *)fpr {
    NSString *returnDataString = @"Error";
    // Export
    char *_out = NULL;
    const char *_fpr=[fpr UTF8String];
    
    int len = 0;
    if (!mi_export((char *)_fpr, 1, 1, &_out, &len)) {
        returnDataString = [NSString stringWithFormat:@"%s",_out];
    }
    xfree(_out);
    _out = NULL;
    return returnDataString;
}



- (NSString *)generateKey:(int) size name:(NSString *)_name comment:(NSString *)_comment email:(NSString *)_email password:(NSString *)_password {
    NSString *returnDataString = @"Error generate keys";
    if (result == 0) {
        char *newkey = NULL;
        const char *cName=[_name UTF8String];
        const char *cComment=[_comment UTF8String];
        const char *cEmail=[_email UTF8String];
        const char *cPassword=[_password UTF8String];
        int returnData = mi_gen_rsa_key(size, (char *)cName, (char *)cComment, (char *)cEmail, 0, (char *)cPassword, &newkey);
        
        if (returnData == 0) returnDataString = [NSString stringWithFormat:@"%s", newkey];
        
        xfree(newkey);
    }
    
    return returnDataString;
}






- (void) passwordIsValid:(NSString *)password fpr:(NSString *)_fpr result:(void (^)(BOOL result)) block {
    
    NSString *message = @"Test validation password";
    [self enacryptMessage:message fpr:_fpr result:^(NSString *resultEncrypt) {
        [self decryptMessage:resultEncrypt password:password result:^(NSString *resultDecrypt) {
            
            if ([resultDecrypt isEqualToString:message]) block(YES);
            else block(NO);
            
        }];
    }];
    
}


- (void)enacryptMessage:(NSString *)message fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block {
    NSString *returnDataString = @"Error enacryp message";

    if (result == 0) {
        char *fpr = (char *)[_fpr UTF8String];
        char *ec = (char *)[message UTF8String];
        int ecl = (int)strlen(ec);
    
        char *outenc = NULL;
        int outlen = 0;
        int rc = mi_encrypt(ec, ecl, NULL, fpr, 1, &outenc, &outlen);
        if (rc == 0) block([NSString stringWithFormat:@"%s", outenc]);
        else block(returnDataString);
        xfree(outenc);
    }else{
        block(returnDataString);
    }
}


- (void)decryptMessage:(NSString *)message password:(NSString *)_password result:(void (^)(NSString *result)) block {
     dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         NSString *returnDataString = @"Error decrypt message";
         if (self->result == 0) {
             //NSLog(@"----------------------");
             //NSLog(@"%@", message);
             NSString *regString = [message stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
             //NSLog(@"----------------------");
             //NSLog(@"%@", regString);
             //NSLog(@"----------------------");
             NSData* storage= [regString dataUsingEncoding:NSUTF8StringEncoding];
             //char *fpr = (char *)[_fpr UTF8String];
             
             char *password = (char *)[_password UTF8String];
             char *dec = (char *)storage.bytes;
             int dlen = (int)storage.length;
        
             __block char *outdec = NULL;
             int outdlen = 0;
             __block char *fname = NULL;
             
             int rc = mi_decrypt(dec, dlen, password, NULL, &outdec, &outdlen, &fname);
             
             dispatch_async(dispatch_get_main_queue(), ^(void){
                 
                 if (rc == 0) block([NSString stringWithUTF8String:outdec]);
                 else block(returnDataString);
                 
                 xfree(outdec);
                 xfree(fname);
                 
             });
        
             
         }else
             block(returnDataString);
     });
}

- (void)decryptData:(NSData *)data password:(NSString *)_password result:(void (^)(NSString *result)) block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *returnDataString = @"Error decrypt message";
        if (self->result == 0) {
            //char *fpr = (char *)[_fpr UTF8String];
            char *password = (char *)[_password UTF8String];
            char *dec = (char *)data.bytes;
            int dlen = (int)data.length;
            
            __block char *outdec = NULL;
            int outdlen = 0;
            __block char *fname = NULL;
            int rc = mi_decrypt(dec, dlen, password, NULL, &outdec, &outdlen, &fname);
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                if (rc == 0) block([NSString stringWithUTF8String:outdec]);
                else block(returnDataString);
                
                xfree(outdec);
                xfree(fname);
                
            });
            
            
        }else
            block(returnDataString);
    });
}


//result mi_decrypt_data:0

-(NSString *) removeLine:(NSString *)message {
    NSString *stringWithoutSpaces = [message stringByReplacingOccurrencesOfString:@"-----BEGIN PGP MESSAGE-----\n\n" withString:@""];
    NSString *newMessage = [stringWithoutSpaces stringByReplacingOccurrencesOfString:@"\n-----END PGP MESSAGE-----\n" withString:@""];
    return newMessage;
}

- (NSString *) addHeaders:(NSString *)message {
    return [NSString stringWithFormat:@"-----BEGIN PGP MESSAGE-----\n\n%@\n-----END PGP MESSAGE-----\n", message];
}


- (void)enacryptMessageNoHeader:(NSString *)message fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block {
    NSString *returnDataString = @"Error enacryp message";
    
    //65FB31620130FFC668F04E2B488AE5D13BBCE719 - iPad
    
    if (result == 0) {
        char *fpr = (char *)[_fpr UTF8String];
        char *ec = (char *)[message UTF8String];
        int ecl = (int)strlen(ec);
        
        char *outenc = NULL;
        int outlen = 0;
        int rc = mi_encrypt(ec, ecl, NULL, fpr, 1, &outenc, &outlen);
        
        
        
        if (rc == 0) {
            NSString *stringRemoveLine = [self removeLine:[NSString stringWithFormat:@"%s", outenc]];
          block(stringRemoveLine);
        }else
            block(returnDataString);
        xfree(outenc);
    }else{
        block(returnDataString);
    }
}


- (void) decryptMessageNoHeader:(NSString *)message password:(NSString *)_password result:(void (^)(NSString *result)) block{
    NSString *returnDataString = @"Error decrypt message";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
        if (self->result == 0) {
            if (![message isEqualToString:@""]) {
                
                NSData* storage= [[self addHeaders:message] dataUsingEncoding:NSUTF8StringEncoding];
                
                char *password = (char *)[_password UTF8String];
                char *dec = (char *)storage.bytes;
                int dlen = (int)storage.length;
            
                __block char *outdec = NULL;
                int outdlen = 0;
                __block char *fname = NULL;
                
                int rc = mi_decrypt(dec, dlen, password, NULL, &outdec, &outdlen, &fname);
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    if (rc == 0)
                        block([NSString stringWithUTF8String:outdec]);
                    else
                        block(returnDataString);
                    
                    xfree(outdec);
                    xfree(fname);
                    
                });
                
            } else
                block(returnDataString);
        } else
            block(returnDataString);
    });
    
}








- (void)enacryptFile:(NSString *)file fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block {
    if (result == 0) {
        char *fpr = (char *)[_fpr UTF8String];
        NSString *fliePart = [[self _filePath] stringByAppendingPathComponent:file];
        
        char *_file = (char *)[fliePart UTF8String];
        int overwrite = 0;
        int rc = mi_encrypt_file(_file, fpr, 0, overwrite);
        if (rc == 0)
            block([NSString stringWithFormat:@"%@.gpg", file]);
        else
            block(@"Error enacrypt file");
    } else {
        block(@"Error enacrypt file");
    }
}


- (void)decryptFile:(NSString *)file password:(NSString *)_password  result:(void (^)(NSString *result)) block {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (self->result == 0) {
        
        NSString *fliePart = [[self _filePath] stringByAppendingPathComponent:file];
        
        char *file = (char *)[fliePart UTF8String];
        char *password = (char *)[_password UTF8String];
        __block char *outFile = NULL;
        int overwrite = 0;
        
        int rc = mi_decrypt_file(file, password, NULL, &outFile, overwrite);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (rc == 0) {
                if (outFile != NULL) block([NSString stringWithUTF8String:outFile]);
                else
                    block(@"Error decrypt file");
            }
            xfree(outFile);
        });
        
    }else{
        block(@"Error decrypt file");
    }
     });
    
}










- (void)enacryptNoArmorMessage:(NSString *)message fpr:(NSString *)_fpr result:(void (^)(NSString *result)) block {
    NSString *returnDataString = @"Error enacryp message";

    if (result == 0) {
        char *fpr = (char *)[_fpr UTF8String];
        NSData* messageData= [message dataUsingEncoding:NSUTF8StringEncoding];
        char *ec = (char *)messageData.bytes;
        int ecl = (int)messageData.length;
        
        char *outenc = NULL;
        int outlen = 0;
        int rc = mi_encrypt(ec, ecl, NULL, fpr, 0, &outenc, &outlen);
        if (rc == 0) {
            NSData *messageDataDecrypt = [[NSData dataWithBytes:outenc length:outlen] copy];
            returnDataString = [messageDataDecrypt base64EncodedStringWithOptions:0];
            if (returnDataString != NULL) block(returnDataString);
        }else{
            block(returnDataString);
        }
        xfree(outenc);
    }else{
        block(returnDataString);
    }
}

- (void)decryptNoArmorMessage:(NSString *)message password:(NSString *)_password result:(void (^)(NSString *result)) block {
    
    
     dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         NSString *returnDataString = @"Error decrypt message";
         if (self->result == 0) {
             NSData *messageData = [[NSData alloc] initWithBase64EncodedString:message options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
             //char *fpr = (char *)[_fpr UTF8String];
        
             char *dec = (char *)messageData.bytes;
             int dlen = (int)messageData.length;
        
             __block char *outdec = NULL;
             int outdlen = 0;
             __block char *fname = NULL;
             char *password = (char *)[_password UTF8String];
             int rc = mi_decrypt(dec, dlen, password, NULL, &outdec, &outdlen, &fname);
             
             dispatch_async(dispatch_get_main_queue(), ^(void){
                 
                 if (rc == 0) {
                     NSData *messageDataDecrypt = [[NSData dataWithBytes:outdec length:outdlen] copy];
                     if ([NSString stringWithUTF8String:[messageDataDecrypt bytes]] != NULL)
                         block([NSString stringWithUTF8String:[messageDataDecrypt bytes]]);
                        else
                            block(returnDataString);
                 }else{
                     block(returnDataString);
                 }
                 xfree(outdec);
                 xfree(fname);
                 
             });
             
         }else{
             block(returnDataString);
         }
     });
}



//Delete key
- (BOOL)deleteKey:(NSString *)fpr secret:(int)secret {
    
    if (result == 0) {
        char *_fpr = (char *)[fpr UTF8String];
        int rc =  mi_delete_key(_fpr, secret, 0);
        if (rc == 0){
            return YES;
        }
    }
    return NO;
}



//Key Server action

- (NSMutableArray *) serverKeyList:(NSString *)_server user:(NSString *)_user {
    NSMutableArray *list = [NSMutableArray new];
    if (result == 0) {
        
        char *server = (char *)[_server UTF8String];
        char *user = (char *)[_user UTF8String];
        
        list_key_t *lskeys = NULL;
        //int rc = mi_keyserver_search(server, user, &lskeys);
        int rc = mi_keyserver_search(server, user, NULL, &lskeys);
        
        if (rc == 0) {
            list_key_t *lks = lskeys;
            for(; lks; lks = lks->next) {
                NSMutableDictionary *obj = [NSMutableDictionary new];;
                [obj setObject:[NSString stringWithFormat:@"%u", lks->timestamp] forKey:@"id"];
                [obj setObject:[NSString stringWithFormat:@"%s", lks->uid.name] forKey:@"name"];
                [obj setObject:[NSString stringWithFormat:@"%s", lks->fpr] forKey:@"fpr"];
                [list addObject:obj];
            }
            mi_list_keys_free(lskeys);
        }else{
            NSLog(@"error [%u]: key not searched from server\n", rc);
        }
    }
    return list;
}


- (BOOL)sendKeyToServer:(NSString *)_fpr server:(NSString *)_server {
    if (result == 0) {
        char *server = (char *)[_server UTF8String];
        char *fpr = (char *)[_fpr UTF8String];
        int rc = mi_keyserver_send(server, fpr, NULL);
        //mi_keyserver_send(server, fpr);
        if (rc == 0) return YES;
    }
    return NO;
}

- (NSMutableArray *)importKeyForServer:(NSString *)_server user:(NSString *)_user {
    
    NSMutableArray *list = [NSMutableArray new];
    
    if (result == 0) {
        char *server = (char *)[_server UTF8String];
        char *user = (char *)[_user UTF8String];
        mi_imported_t *get_fpr = NULL;
        int rc = mi_keyserver_name(server, user, NULL, &get_fpr);
        if (rc == 0) {
            mi_imported_t *mp = get_fpr;
            for(; mp; mp = mp->next) {
                //printf("%u %s %s %s\n", mp->stat, mp->fpr, mp->info, mp->short_fpr);
                
                NSMutableDictionary *obj = [NSMutableDictionary new];;
                
                [obj setObject:[NSString stringWithFormat:@"%s", mp->short_fpr] forKey:@"id"];
                [obj setObject:[NSString stringWithFormat:@"%s", mp->info] forKey:@"name"];
                [obj setObject:[NSString stringWithFormat:@"%s",  mp->fpr] forKey:@"fpr"];
                
                [list addObject:obj];
                
            }
        }
        
        else
            printf("error [%u]: key not imported by name from server\n", rc);
        
        mi_import_free(get_fpr);
    }
    
    return list;
}

- (NSMutableArray *)importKeyForServer:(NSString *)_server fpr:(NSString *)_fpr {
    
    NSMutableArray *list = [NSMutableArray new];
    if (result == 0) {
        char *server = (char *)[_server UTF8String];
        char *fpr = (char *)[_fpr UTF8String];
        
        printf("\nRecv key...\n");
        mi_imported_t *recv_fpr = NULL;
        int rc = mi_keyserver_recv(server, fpr, NULL, &recv_fpr);
        if (rc == 0){
            mi_imported_t *mp = recv_fpr;
            for(; mp; mp = mp->next) {
                //printf("%u %s %s %s\n", mp->stat, mp->fpr, mp->info, mp->short_fpr);
                NSMutableDictionary *obj = [NSMutableDictionary new];;
                [obj setObject:[NSString stringWithFormat:@"%s", mp->short_fpr] forKey:@"id"];
                [obj setObject:[NSString stringWithFormat:@"%s", mp->info] forKey:@"name"];
                [obj setObject:[NSString stringWithFormat:@"%s",  mp->fpr] forKey:@"fpr"];
                [list addObject:obj];
            }
        } else {
            printf("error [%u]: key not recv from server\n", rc);
        }
        mi_import_free(recv_fpr);
    }
    return list;
}



- (NSMutableArray *)importKeyForLDAP_HLRServer:(NSString *)_server user:(NSString *)_user {
    NSMutableArray *list = [NSMutableArray new];
    if (result == 0) {
        char *server = (char *)[_server UTF8String];
        char *user = (char *)[_user UTF8String];
        list_key_t *lskeys = NULL;
        
        //"binddn=\"uid=user1,ou=PGP Users,dc=mydomain,dc=com\"\nbindpw=wasd"
        
        int rc = mi_keyserver_search(server, user, "timeout=30", &lskeys);
        //mi_keyserver_search(char *srv, char *search, char *options, list_key_t **lskeys)
        if (rc == 0) {
            list_key_t *mp = lskeys;
            for(; mp; mp = mp->next) {
                //printf("%u %s %s %s\n", mp->stat, mp->fpr, mp->info, mp->short_fpr);
                //printf("%c %s %s %s", mp->status, mp->fpr, mp->key, mp->uid.name);
                
                NSMutableDictionary *obj = [NSMutableDictionary new];;
                
                [obj setObject:[NSString stringWithFormat:@"%c", mp->status] forKey:@"status"];
                [obj setObject:[NSString stringWithFormat:@"%s", mp->uid.name] forKey:@"name"];
                [obj setObject:[NSString stringWithFormat:@"%s", mp->key] forKey:@"key"];
                [obj setObject:[NSString stringWithFormat:@"%s",  mp->fpr] forKey:@"fpr"];
                
                [list addObject:obj];
                
            }
        }
        
        else
            printf("error [%u]: key not imported by name from server\n", rc);
        
        mi_list_keys_free(lskeys);
    }
    
    return list;
}


- (BOOL) changePassword:(NSString *)_oldPassword newPassword:(NSString *)password fpr:(NSString *)privatefpr {
    
    if (result == 0) {
        char *oldpwd = (char *)[_oldPassword UTF8String];
        char *pwd = (char *)[password UTF8String];
        char *fpr = (char *)[privatefpr UTF8String];
        
        int rc = mi_change_passphrase(fpr, oldpwd, pwd);
        if (rc == 0) return YES;
    }
    
    return NO;
}

- (void) deleteAllKayes {
    for (NSDictionary *obj in [self privateKeyList]) {
        NSString *fpr = [obj objectForKey:@"fpr"];
        [self deleteKey:fpr secret:1];
    }
    
    for (NSDictionary *obj in [self publicKeyList]) {
        NSString *fpr = [obj objectForKey:@"fpr"];
        [self deleteKey:fpr secret:0];
    }
    
}


@end
