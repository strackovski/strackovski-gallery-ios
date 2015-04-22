//
//  SSImageGetter.m
//  Retrieves artwork images from HTTP server
//  StrackovskiGallery
//
//  Created by Vladimir Stračkovski on 04/09/14.
//  Copyright (c) 2014 Vladimir Stračkovski. All rights reserved.
//

#import "SSImageGetter.h"
#import "MainViewController.h"

@implementation SSImageGetter

+(SSImageGetter*)sharedInstance
{
    static SSImageGetter *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SSImageGetter alloc]init];
    });
    
    return sharedInstance;
}

-(void)getImages
{
    NSLog(@"Downloading images...");
    int AA = 0;
    
    // File manager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Path to documents
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // Path to plist
    NSString *path = [documents stringByAppendingPathComponent:@"myList.plist"];
    // Server: json file list
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.strackovski.com/en/api/images?q=all"]];
    
    NSError* error;
    NSLog(@"Data Length: %lu", (unsigned long)data.length);
    NSLog(@"Puredata: %@", data);
    NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"data: %@", strData);

    if(!data || data.length == 0) {
        if ([fileManager fileExistsAtPath:path]) {
            NSLog(@"Path already created");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
        } else {
            NSLog(@"Path has not been created yet.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setPlaceholder" object:nil];
        }

        return;
    }
    
    NSLog(@"Yes data");
    
    // Server: get file list
    NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    // Server: root image path
    NSString *serverPath = @"http://www.strackovski.com/web/artwork/";
    // Comparison array
    NSMutableArray *photos = [[NSMutableArray alloc]init];
    NSMutableArray *myArray;
    
    // Check if plist already exists
    if([fileManager fileExistsAtPath:path]) {
        NSLog(@"Path: %@", path);
        NSLog(@"Plist exists...");
        myArray = [[NSMutableArray alloc]initWithContentsOfFile:path];
        NSMutableArray *newItemsArray = [[NSMutableArray alloc]init];

        for(NSDictionary *dict in myArray) {
            [photos addObject:@[[dict objectForKey:@"id"],
                                [NSString stringWithFormat:@"%@.jpg", [dict objectForKey:@"name"]],
                                [dict objectForKey:@"title"]]
             ];
        }

        // Check if server has same number of items as locally stored file
        if (photos.count != result.count) {
            NSLog(@"Images not synced");
            
            // Extract arrays of images (and titles) that aren't stored locally for comparison
            for(NSArray *array in result) {
                [newItemsArray addObject:@[[array valueForKey:@"id"], [array valueForKey:@"name"], [array valueForKey:@"title"]]];
            }
            
            //
            // Detect local items not present in server response
            NSMutableArray *itemsToRemove = photos;
            [itemsToRemove removeObjectsInArray:newItemsArray];
            [photos removeObjectsInArray:itemsToRemove];
            
            NSLog(@"Passed detection");
            
            // Remove local items not present in server response
            // from local storage and plist
            if (itemsToRemove.count > 0) {
                NSLog(@"Removal pending");
                NSMutableArray *plistArray = [[NSMutableArray alloc]initWithContentsOfFile:path];
                for(NSDictionary *dict in plistArray) {
                    NSString *photoId = [dict objectForKey:@"id"];
                    NSString *photoName = [dict objectForKey:@"name"];
                    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", photoName];
                    
                    for(NSArray *array in photos) {
                        if([[array firstObject] isEqualToString:photoId]) {
                            [itemsToRemove addObject:dict];
                            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@.jpeg", documents, photoName] error:nil];
                        }
                    }
                }
                
                [plistArray removeObjectsInArray:itemsToRemove];
                [plistArray writeToFile:path atomically:YES];
                NSLog(@"Some images got removed");
                NSLog(@"In sync again");
            }
            
            // Check if serverArray is different from localArray
            // arrayDiff = array dif ( serverArray localArray )
            // localArray.append( arrayDiff )
            NSArray *newItemsArraySorted = [NSArray arrayWithArray:newItemsArray];
            NSArray *photosSorted = [NSArray arrayWithArray:photos];
            
            // NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"id" ascending: NO];
            // newItemsArraySorted = [newItemsArraySorted sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
            // photosSorted = [photosSorted sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
            
            // newItemsArraySorted = [newItemsArraySorted sortedArrayUsingSelector:@selector(compare:)];
            // photosSorted = [photosSorted sortedArrayUsingSelector:@selector(compare:)];
            
            if (![newItemsArraySorted isEqualToArray:photosSorted]) {
                NSLog(@"Add new items...");
                [newItemsArray removeObjectsInArray:photos];
                [photos addObjectsFromArray:newItemsArray];
                
                // Fetch new items from server
                for (NSArray *array in newItemsArray) {
                    //NSString *imageId = [array objectAtIndex:0];
                    NSString *imageName = [array objectAtIndex:1];
                    NSString *titleName = [array objectAtIndex:2];
                    NSArray *parts = [imageName componentsSeparatedByString:@"."];
                    NSArray *fileName = [parts firstObject];
                    
                    // Get image from server
                    NSString *serverImagePath = [NSString stringWithFormat:@"%@/%@", serverPath, imageName];
                    UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:serverImagePath]]];
                    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@.jpeg", documents, fileName];
                    NSData *data1 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
                    
                    if(AA == 1) {
                        [fileManager removeItemAtPath:jpegFilePath error:nil];
                    } else {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:2];
                        [dict setObject:fileName forKey:@"name"];
                        [dict setObject:titleName forKey:@"title"];
                        [data1 writeToFile:jpegFilePath atomically:YES];
                        [myArray addObject:dict];
                    }
                }
                
                if(AA == 1) {
                    [fileManager removeItemAtPath:path error:nil];
                } else {
                    [myArray writeToFile:path atomically:YES];
                    NSLog(@"Some images added");
                    NSLog(@"In sync again");
                    NSLog(@"posted notification!");
                }
            }
            
            
            /*
            // If server has more - add new items
            if(result.count > photos.count) {
                
                //[newItemsArray removeObjectsInArray:photos];
                // Fetch new items from server
                for (NSArray *array in newItemsArray) {
                    NSString *imageName = [array firstObject];
                    NSString *titleName = [array lastObject];
                    NSArray *parts = [imageName componentsSeparatedByString:@"."];
                    NSArray *fileName = [parts firstObject];
                    
                    // Get image from server
                    NSString *serverImagePath = [NSString stringWithFormat:@"%@/%@", serverPath, imageName];
                    UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:serverImagePath]]];
                    NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@.jpeg", documents, fileName];
                    NSData *data1 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
                    
                    if(AA == 1) {
                        [fileManager removeItemAtPath:jpegFilePath error:nil];
                    } else {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:2];
                        [dict setObject:fileName forKey:@"name"];
                        [dict setObject:titleName forKey:@"title"];
                        [data1 writeToFile:jpegFilePath atomically:YES];
                        [myArray addObject:dict];
                    }
                }
                
                if(AA == 1) {
                    [fileManager removeItemAtPath:path error:nil];
                } else {
                    [myArray writeToFile:path atomically:YES];
                    NSLog(@"Some images added");
                    NSLog(@"In sync again");
                    NSLog(@"posted notification!");
                }
               // [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
            }
            // If local file has more items - remove them
            else {
                NSMutableArray *itemsToRemove = [[NSMutableArray alloc]init];
                [photos removeObjectsInArray:newItemsArray];
                NSMutableArray *plistArray = [[NSMutableArray alloc]initWithContentsOfFile:path];
                for(NSDictionary *dict in plistArray) {
                    NSString *photoName = [dict objectForKey:@"name"];
                    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", photoName];
                    
                    for(NSArray *array in photos) {
                        if([[array firstObject] isEqualToString:fileName]) {
                            [itemsToRemove addObject:dict];
                            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@.jpeg", documents, photoName] error:nil];
                        }
                    }
                }
                
                [plistArray removeObjectsInArray:itemsToRemove];
                [plistArray writeToFile:path atomically:YES];
                NSLog(@"Some images got removed");
                NSLog(@"In sync again");
            }
            NSLog(@"Images werent synced");
             */
        }
    
        NSLog(@"Images EXISTENT");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
    } else {
        NSLog(@"No images in local storage.");
        // Plist has not been created yet
        // Get all images from server
        myArray = [NSMutableArray array];
        
        for (NSArray *innerArray in result) {
            NSString *imageId = [innerArray valueForKey:@"id"];
            NSString *imageName = [innerArray valueForKey:@"name"];
            NSString *titleName = [innerArray valueForKey:@"title"];
            
            //save image
            NSArray *parts = [imageName componentsSeparatedByString:@"."];
            NSString *fileName = [parts firstObject];
            
            // Get image from server
            NSString *serverImagePath = [NSString stringWithFormat:@"%@/%@", serverPath, imageName];
            UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:serverImagePath]]];
            NSString *jpegFilePath = [NSString stringWithFormat:@"%@/%@.jpeg", documents,fileName];
            NSData *data1 = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];

            if(AA == 1) {
                [fileManager removeItemAtPath:jpegFilePath error:nil];
            } else {
                [data1 writeToFile:jpegFilePath atomically:YES];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
                [dictionary setObject:imageId forKey:@"id"];
                [dictionary setObject:fileName forKey:@"name"];
                [dictionary setObject:titleName forKey:@"title"];
                [myArray addObject:dictionary];
            }
        }
        
        if(AA == 1) {
            [fileManager removeItemAtPath:path error:nil];
        } else {
            [myArray writeToFile:path atomically:YES];
            if([fileManager fileExistsAtPath:path]) {

                NSArray *tempArray = [[NSArray alloc]initWithContentsOfFile:path];
                int xx = (int)tempArray.count;
                for(NSDictionary *dict in tempArray) {
                    NSLog(@"Dict value: %@",[dict valueForKey:@"name"]);
                    xx--;
                }
                if(xx == 0) {
                    NSLog(@"Files written!!!!");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshView" object:nil];
                }
            }
        }
    }
}

@end
