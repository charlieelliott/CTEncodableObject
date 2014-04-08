CTEncodableObject
=================

Base class which implements NSCoding, NSCopying for encoding, debugging, and quickLook.

This class basically falls down to one method, which returns a set of property names for that class which are readwrite and have storage
``` objc
+ (NSMutableSet *)encodableKeys;
```

Because each class' properties are it's own, we must first call this method on it's superclass, and so-on, all the way up to NSObject.
``` objc
    NSMutableSet *temp = [NSMutableSet set];
    Class superClass = class_getSuperclass(self);
    Method method = class_getClassMethod(superClass, _cmd);
    if(method != NULL)
        [temp unionSet:[superClass encodableKeys]]; //recursively get superclass properties
```

This is basically the crux of this class. We iterate through each of our properties using the 
objc-runtime method class_copyPropertyList(). We then inspect the attributes of each property, ensuring
they are not weak and have storage (!readonly && !weak). If the property meets this criterea, we add it
to the set of properties and move on to the next one.
``` objc
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for(int i = 0; i < count; i++)
    {
        objc_property_t prop = properties[i];
        char *readonly = property_copyAttributeValue(prop, ct_PropertyAttributeValueReadonly);
        char *weak = property_copyAttributeValue(prop, ct_PropertyAttributeValueWeak);
        if(!readonly && !weak)
            [temp addObject:@(property_getName(prop))];
        free(readonly);
        free(weak);
    }
    free(properties);
```

Lastly, remove any explicitly declared keys which should not be included, free up the memory, and return!
``` objc
    [temp minusSet:[self unencodableKeys]];
    
    return temp;
```

License
-------
CTEncodableObject is available under the MIT license. See the LICENSE file for more info.