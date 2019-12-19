//
//  WHCCAnnotation.h
//  tztAppV4
//
//  Created by it-kangming on 2019/12/17.
//  Copyright © 2019 king. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHCC.h"

#ifndef WHCCModSectName

#define WHCCModSectName "WHCCMods"

#endif

#ifndef WHCCServiceSectName

#define WHCCServiceSectName "WHCCServices"

#endif


#define WHCCDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))



#define WHCCMod(name) \
class WHCC; char * k##name##_mod WHCCDATA(WHCCMods) = ""#name"";

#define WHCCService(servicename,impl) \
class WHCC; char * k##servicename##_service WHCCDATA(WHCCServices) = "{ \""#servicename"\" : \""#impl"\"}";

@interface WHCCAnnotation : NSObject

@end

