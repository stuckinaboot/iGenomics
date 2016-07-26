//
//  MutationInfo.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 6/23/13.
//
//

#import "MutationInfo.h"

@implementation MutationInfo

@synthesize pos, displayedPos, refChar,
    foundChars, genomeName, indexInSegmentNameArr, relevantInsertionsArr;

- (id)initWithPos:(int)p andRefChar:(char)refC andFoundChars:(char *)foundC andDisplayedPos:(int)dispP  andInsertionsArr:(NSArray*)insArr heteroAllowance:(float)heteroAllowance {
    self = [super init];
    pos = p;
    displayedPos = dispP;
    refChar = refC;
    foundChars = strdup(foundC);
    
    NSMutableArray *insertions = [[NSMutableArray alloc] init];
    for (BWT_Matcher_InsertionDeletion_InsertionHolder *holder in insArr) {
        if (pos == holder.pos && ((float)holder.count / coverageArray[pos]) >= heteroAllowance) {
            [insertions addObject:holder];
        }
    }
    
    //Remove the + from foundChars if insertions size is 0 and there was a +
    if ([insertions count] == 0) {
        int numFoundChars = (int)strlen(foundChars);
        if (foundChars[numFoundChars - 1] == kInsMarker) {
            foundChars[numFoundChars - 1] = '\0';
            numFoundChars--;
        }
        
        //Check if a mutation is no longer present
        if (numFoundChars == 1)
            if (foundChars[numFoundChars - 1] == refChar)
                return NULL;
        if (numFoundChars == 0)
            return NULL;
    }
    
    relevantInsertionsArr = insertions;
    return self;
}

+ (NSString*)mutationInfosOutputString:(NSArray*)mutationInfos {
    NSLog(@"Generating mutation info output string");
    NSMutableArray *mutationInfosDicts = [NSMutableArray array];
    for (MutationInfo *info in mutationInfos) {
        [mutationInfosDicts addObject:[info describingDictionary]];
    }
    
    NSLog(@"Mutation info dictionaries filled");
    
    NSMutableString *output = [NSMutableString string];
    NSArray *finalDicts = [MutationInfo mutationInfoDictsByCompressingDeletions:mutationInfosDicts];
    
    NSLog(@"All deletions compressed");
    
    for (NSDictionary *dict in finalDicts) {
        [output appendFormat:@"%@\n", [MutationInfo descriptionFromMutationInfoDict:dict]];
    }
    NSLog(@"Descriptions from dictionaries finished");
    return output;
}

+ (NSArray*)mutationInfoDictsByCompressingDeletions:(NSMutableArray*)mutationInfoDicts {
    NSString *delMarkerStr = [NSString stringWithFormat:@"%c", kDelMarker];
    
    NSMutableArray *mutationInfoDictsOutputArr = [NSMutableArray array];
    for (int i = 0; i < [mutationInfoDicts count]; i++) {
        NSMutableDictionary *info = [mutationInfoDicts objectAtIndex:i];
        
//        if ([info[@"type"] isEqualToString:@"DELETION"]) {
        if ([info[@"allele frequencies"] objectForKey:delMarkerStr] != nil) {
            NSMutableString *compressedDel = [NSMutableString stringWithString:info[@"reference"][@"normal"]];
            for (int j = i + 1; j < [mutationInfoDicts count]; j++) {
                NSMutableDictionary *nextInfo = [mutationInfoDicts objectAtIndex:j];
                if ([nextInfo[@"allele frequencies"] objectForKey:delMarkerStr] != nil
//                if ([nextInfo[@"type"] isEqualToString:@"DELETION"]
                    && [nextInfo[@"chromosome"] isEqualToString:info[@"chromosome"]]
                    && [nextInfo[@"position"] intValue] == [info[@"position"] intValue] + 1) {
                    //Merge the deletions
                    [compressedDel appendString:nextInfo[@"reference"][@"normal"]];
                    nextInfo = [MutationInfo mutationInfoDictByRemovingDeletion:nextInfo];
                    if (nextInfo == NULL) {
                        [mutationInfoDicts removeObjectAtIndex:j];
                        j--;
                    } else
                        break;
                }
            }
//            info[@"reference"] = compressedDel;
            
            //Move the deletion mutation back one position and make the ref char at that back position the found char and prepend it to the reference field.
            BOOL delAdjusted = NO;
            if (i > 0) {
                //Case 1: if there is a mutation at that position that the deletion should be added to
                NSMutableDictionary *prevInfo = [mutationInfoDicts objectAtIndex:i - 1];
                if ([prevInfo[@"position"] intValue] + 1 == [info[@"position"] intValue] && [prevInfo[@"chromosome"] isEqualToString:info[@"chromosome"]]) {
                    NSMutableDictionary *alleleFreqs = prevInfo[@"allele frequencies"];
                    
                    int internalPos = ((MutationInfo*)prevInfo[@"mutation info"]).pos;
//                    int internalPos = [prevInfo[@"position"] intValue] - 1;
                    float delFreq = posOccArray[4][internalPos + 1] / ((float)(posOccArray[4][internalPos + 1] + coverageArray[internalPos]));
                    alleleFreqs[delMarkerStr] = @(delFreq);
                    prevInfo[@"reference"][@"deletion"] = [NSString stringWithFormat:@"%@%@", prevInfo[@"reference"][@"normal"], compressedDel];
                    
//                    prevInfo[@"found"] = [NSString stringWithFormat:@"%@,%@", prevInfo[@"reference"], prevInfo[@"found"]];
                    info = [MutationInfo mutationInfoDictByRemovingDeletion:info];
                    delAdjusted = YES;
                }
            }
            if (!delAdjusted) {
                //Case 2: No mutation to be added to, need to create a new mutation at the previous position
                NSMutableDictionary *prevPosDict = [NSMutableDictionary dictionary];
                
                int newInternalPos = ((MutationInfo*)info[@"mutation info"]).pos - 1;//[info[@"position"] intValue] - 2;//Because info position refers to the displayed pos, which is the internal pos + 1
                
                prevPosDict[@"position"] = @([info[@"position"] intValue] - 1);
                prevPosDict[@"mutation info"] = [[MutationInfo alloc] initWithPos:newInternalPos andRefChar:'f' andFoundChars:"foo" andDisplayedPos:0 andInsertionsArr:NULL heteroAllowance:0];
//                info[@"position"] = @(newInternalPos + 1);
                NSString *refBase = [NSString stringWithFormat:@"%c", originalStr[newInternalPos]];
                prevPosDict[@"reference"] = [NSMutableDictionary dictionary];
                prevPosDict[@"chromosome"] = info[@"chromosome"];
                prevPosDict[@"reference"][@"normal"] = refBase;
                prevPosDict[@"reference"][@"deletion"] = [NSString stringWithFormat:@"%@%@", refBase, compressedDel];

                NSNumber* delFreq = info[@"allele frequencies"][[NSString stringWithFormat:@"%c", kDelMarker]];
                prevPosDict[@"allele frequencies"] = [NSMutableDictionary dictionary];
                prevPosDict[@"allele frequencies"][delMarkerStr] = delFreq;
                float delFreqFloat = [delFreq floatValue];
                if (delFreqFloat > 0) {
                    prevPosDict[@"allele frequencies"][refBase] = [NSNumber numberWithFloat:1 - [delFreq floatValue]];
                }
                [mutationInfoDictsOutputArr addObject:prevPosDict];
                info = [MutationInfo mutationInfoDictByRemovingDeletion:info];
            }
            
        }
        if (info != NULL)
            [mutationInfoDictsOutputArr addObject:info];
//            [mutationInfoDictsOutputArr addObject:info];
//        } else {
//            [mutationInfoDictsOutputArr addObject:info];
//        }
            
    }
    return mutationInfoDictsOutputArr;
}

+ (NSMutableDictionary*)mutationInfoDictByRemovingDeletion:(NSMutableDictionary*)mutInfoDict {
//    mutInfoDict[@"found"] =
//        [mutInfoDict[@"found"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    
//    //In case there were multiple found bases
//    mutInfoDict[@"found"] =
//        [mutInfoDict[@"found"] stringByReplacingOccurrencesOfString:@",," withString:@""];
    [mutInfoDict[@"allele frequencies"] removeObjectForKey:@"-"];
    [mutInfoDict[@"reference"] removeObjectForKey:@"deletion"];
    NSDictionary *alleleFreqsDict = (NSDictionary*)mutInfoDict[@"allele frequencies"];
    
    //If the only remaining allele is the reference, then at that point there is no mutation
    if ([alleleFreqsDict count] == 1
        && [alleleFreqsDict objectForKey:mutInfoDict[@"reference"][@"normal"]] != nil)
        return NULL;
    if ([alleleFreqsDict count] > 0)
        return mutInfoDict;
    else
        return NULL;
}

- (NSMutableDictionary*)describingDictionary {
    
    //First create dictionay with the basic information
    NSMutableDictionary *dict =
    [NSMutableDictionary dictionaryWithDictionary:
        @{
          @"chromosome": self.genomeName,
          @"mutation info": self,
          @"position": @(displayedPos + 1)
          }
     ];
    
    //Next determine the frequency of each base in the mutation
    NSMutableDictionary *covDict = [NSMutableDictionary dictionary];
    int len = (int)strlen(foundChars);
    char highestCovChar = kACGTwithInDels[0];
    float highestCovVal = 0;
    for (int i = 0; i < len; i++) {
        char c = foundChars[i];
        int cIndex = [BWT_MatcherSC whichChar:c inContainer:kACGTwithInDels];
        float covVal;
        if (c != kInsMarker) {
            covVal = ((float)posOccArray[cIndex][pos]) / coverageArray[pos];
            covDict[[NSString stringWithFormat:@"%c", c]] = @(covVal);
            
            //Finds highest coverage char that is not the ref char (since we already know there is a mutation here, we are trying to figure out what type of mutation it is
            if (covVal > highestCovVal && c != originalStr[pos]) {
                highestCovChar = c;
                highestCovVal = covVal;
            }
        }
        else {
            NSMutableDictionary *insDict = [NSMutableDictionary dictionary];
            for (BWT_Matcher_InsertionDeletion_InsertionHolder *insertion in relevantInsertionsArr) {
                covVal = ((float)insertion.count) / coverageArray[pos];
                insDict[[NSString stringWithFormat:@"%s", insertion.seq]] = @(covVal);
                
                //Finds highest coverage char that is not the ref char (since we already know there is a mutation here, we are trying to figure out what type of mutation it is
                if (covVal > highestCovVal && c != originalStr[pos]) {
                    highestCovChar = c;
                    highestCovVal = covVal;
                }
            }
            covDict[[NSString stringWithFormat:@"%c", c]] = insDict;
        }
    }
    dict[@"allele frequencies"] = covDict;
    
    //Next determine the type of insertion
    switch (highestCovChar) {
        case kInsMarker:
            dict[@"type"] = @"INSERTION";
            break;
        case kDelMarker:
            dict[@"type"] = @"DELETION";
            break;
        default:
            dict[@"type"] = @"SUBSTITUTION";
            break;
    }
    
    //Next determine the correct reference and found strings
    dict[@"reference"] = [NSMutableDictionary dictionaryWithDictionary:
                          @{
                            @"normal": [NSString stringWithFormat:@"%c", refChar],
                            }];

    
    
    
    
    
//    NSMutableString *foundStr = [NSMutableString string];
//    NSString *insMarkerStr = [NSString stringWithFormat:@"%c", kInsMarker];
//
//    NSArray *sortedKeys = [covDict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        return [obj1 floatValue] < [obj2 floatValue];
//    }];
//    
//    int keyNum = 0;
//    for (NSString *key in sortedKeys) {
//        if ([key isEqualToString:insMarkerStr]) {
//            NSDictionary *insDict = covDict[key];
//            for (NSString *insKey in [insDict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//                return [obj1 floatValue] < [obj2 floatValue];
//            }]) {
//                NSString *seq = [[insDict objectForKey:insKey] stringValue];
//                [foundStr appendFormat:@"%@%@", seq, (keyNum < [sortedKeys count] - 1) ? @"," : @""];
//            }
//        } else {
//            [foundStr appendFormat:@"%@%@", key, (keyNum < [sortedKeys count] - 1) ? @"," : @""];
//        }
//        keyNum += 1;
//    }
//    dict[@"found"] = foundStr;
    
    return dict;
}

+ (NSString*)descriptionFromMutationInfoDict:(NSDictionary*)dict {
    NSMutableString *info = [NSMutableString stringWithString:@"AF="];
    
    NSDictionary *alleleFreqsDict = dict[@"allele frequencies"];
    NSArray *sortedAlleleKeys = [alleleFreqsDict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isKindOfClass:[NSDictionary class]] || [obj2 isKindOfClass:[NSDictionary class]])
            return TRUE;
        return [obj1 floatValue] < [obj2 floatValue];
    }];
    
    NSMutableString *foundStr = [NSMutableString string];
    NSMutableString *refStr = [NSMutableString string];
    NSString *insMarkerStr = [NSString stringWithFormat:@"%c", kInsMarker];
    NSString *delMarkerStr = [NSString stringWithFormat:@"%c", kDelMarker];
    
    int keyNum = 0;
    BOOL normalRefAlreadyAdded = NO;
    BOOL delOccurred = [sortedAlleleKeys containsObject:delMarkerStr];
    for (NSString *allele in sortedAlleleKeys) {
        if ([allele isEqualToString:dict[@"reference"][@"normal"]])
            continue;
        if ([allele isEqualToString:delMarkerStr]) {
            BOOL shouldAddRef = (!([alleleFreqsDict count] == 2 && [alleleFreqsDict objectForKey:dict[@"reference"][@"normal"]] != nil));
            if (keyNum == 0 && [sortedAlleleKeys count] == 1) {
                [refStr appendFormat:@"%@", dict[@"reference"][@"deletion"]];
                normalRefAlreadyAdded = YES;//We don't need to add it so we set this to yes
            } else if (keyNum == 0) {
                [refStr appendFormat:@"%@", dict[@"reference"][@"deletion"]];
//                if (shouldAddRef)
//                    [refStr appendFormat:@",%@",dict[@"reference"][@"normal"]];
                normalRefAlreadyAdded = YES;
            } else if (keyNum > 0) {
//                if (shouldAddRef)
//                    [refStr appendFormat:@"%@,", dict[@"reference"][@"normal"]];
                [refStr appendFormat:@"%@",
                 dict[@"reference"][@"deletion"]];
                normalRefAlreadyAdded = YES;
            }
        }
        if ([allele isEqualToString:insMarkerStr]) {
            NSDictionary *insDict = alleleFreqsDict[allele];
            NSArray *sortedInsKeys = [insDict keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 floatValue] < [obj2 floatValue];
            }];
            for (NSString *insKey in sortedInsKeys) {
                NSString *seq = insKey;
//                [info appendFormat:@"%@,", [insDict[insKey] stringValue]];
                [foundStr appendFormat:@"%@,", seq];
            }
        } else {
//            [info appendFormat:@"%@,", [alleleFreqsDict[allele] stringValue]];
            if ([allele isEqualToString:delMarkerStr]) {
                [foundStr appendFormat:@"%@,", dict[@"reference"][@"normal"]];
            } else {
                NSMutableString *foundAllele = [NSMutableString stringWithString:allele];
                if (delOccurred)
                    [foundAllele appendFormat:@"%@", [((NSString*)dict[@"reference"][@"deletion"]) substringFromIndex:1]];
                [foundStr appendFormat:@"%@,", foundAllele];
            }
    }
        keyNum += 1;
    }
    
    int insDictCount = [((NSDictionary*)alleleFreqsDict[insMarkerStr]) count];
    [info appendFormat:@"%0.003f", 1.0f / (MAX([alleleFreqsDict count] + insDictCount + ((insDictCount > 0) ? -1 : 0), [((NSDictionary*)dict[@"reference"]) count]))];//- 1 accounts for considering the '+' key
    
    if (!normalRefAlreadyAdded) {
        if (!(delOccurred && [alleleFreqsDict count] == 2 && [alleleFreqsDict objectForKey:dict[@"reference"][@"normal"]] != nil))
            [refStr appendFormat:@"%@", dict[@"reference"][@"normal"]];
//        normalRefAlreadyAdded = TRUE;
    }

    @try {
        [foundStr replaceCharactersInRange:NSMakeRange([foundStr length] - 1, 1) withString:@""];//Removes last comma
    } @catch (NSException *exception) {
        NSLog(@"stop");
    }
//    [foundStr replaceCharactersInRange:NSMakeRange([foundStr length] - 1, 1) withString:@""];//Removes last comma

    [info replaceCharactersInRange:NSMakeRange([info length] - 1, 1) withString:@""];//Removes last comma
    
    NSString *gtVal;
    
    if ([alleleFreqsDict count] == 1) {
        //Sample is homozygous alternate
        gtVal = @"1/1";
    } else if ([alleleFreqsDict count] > 1) {
        NSMutableString *heteroStr = [NSMutableString string];
        //Sample is heterozygous
        BOOL containsRef = ([alleleFreqsDict objectForKey:dict[@"reference"][@"normal"]] != nil);
        for (int i = (containsRef) ? 0 : 1, cnt = 0; cnt < [alleleFreqsDict count]; cnt++, i++) {
            [heteroStr appendFormat:@"%d/", i];
        }

        [heteroStr replaceCharactersInRange:NSMakeRange([heteroStr length] - 1, 1) withString:@""];
        gtVal = heteroStr;
    }
    
    NSString *dpVal = [NSString stringWithFormat:@"%d", (coverageArray[((MutationInfo*)dict[@"mutation info"]).pos])];
    
    return [NSString stringWithFormat:@"%@\t%i\t.\t%@\t%@\t30\tPASS\t%@\tGT:DP\t%@",
            dict[@"chromosome"],
            [dict[@"position"] intValue],
            refStr,
            foundStr,
            info,
            [NSString stringWithFormat:@"%@:%@", gtVal, dpVal]];
}

+ (char*)createMutStrFromOriginalChar:(char)originalC
                        andFoundChars:(char*)fc pos:(int)pos relevantInsArr:(NSArray*)insertions {
    int s = (int)strlen(fc);
    NSMutableString *mutStr = [[NSMutableString alloc] init];
    [mutStr appendFormat:@"%c",originalC];
    [mutStr appendFormat:@"%c",'>'];
    
    for (int i = 0; i<s; i++) {
        [mutStr appendFormat:@"%c",fc[i]];
        if (i+1 < s) {
            [mutStr appendFormat:@"%c",'/'];
        }
    }
    return strdup([mutStr UTF8String]);
}

+ (char*)createMutCovStrFromFoundChars:(char*)fc
                                andPos:(int)pos relevantInsArr:(NSArray *)insertions {
    int len = (int)strlen(fc);
    int covArr[len];
    
    NSMutableString *covStr = [[NSMutableString alloc] init];
    for (int i = 0; i < len; i++) {
        covArr[i] = posOccArray[[BWT_MatcherSC whichChar:fc[i] inContainer:acgt]][pos];
        if (fc[i] == kInsMarker) {
            NSMutableString *strToAppend = [[NSMutableString alloc] init];
            for (BWT_Matcher_InsertionDeletion_InsertionHolder *holder in insertions) {
                if (holder.pos == pos) {
                    [strToAppend appendFormat:kInsStrFormat,holder.seq,holder.count];
                }
            }
            [covStr appendFormat:kCovStrInsFormat, kInsMarker, strToAppend];
        } else
            [covStr appendFormat:kCovStrFormat,fc[i],covArr[i]];
    }
    return strdup([covStr UTF8String]);//Replaces the final / with nothing
}

+ (BOOL)mutationInfoObjectsHaveSameContents:(MutationInfo *)info1 :(MutationInfo *)info2 {
    BOOL sameFoundChars = NO;
    int len = (int)strlen(info1.foundChars);
    if (len > 1 && foundGenome[kFoundGenomeArrSize-1][info1.pos] != kMatchTypeHomozygousMutationNormal && foundGenome[kFoundGenomeArrSize-1][info1.pos] != kMatchTypeHomozygousNoMutation) {
        for (int i = 0; i < len; i++) {
            if (info2.foundChars[0] == info1.foundChars[i]) {
                sameFoundChars = YES;
                break;
            }
        }
    }
    else if (len == 1)
        sameFoundChars = (info1.foundChars[0] == info2.foundChars[0]);
    return ((info1.pos == info2.pos) && (info1.refChar == info2.refChar) && sameFoundChars && [info1.genomeName isEqualToString:info2.genomeName]);//Checks if a bunch of factors are equal, foundChars[0] because is just checking first character...may change in future to strcmp
}
@end
