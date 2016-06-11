//
//  FileChooser.m
//  iGenomics
//
//  Created by Stuckinaboot Inc. on 12/1/12.
//
//

#import "FileChooser.h"

@interface FileChooser ()

@end

@implementation FileChooser

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    defaultReads = [[NSArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultReadsListFileName ofType:kDefaultReadsListFileType] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    defaultSequences = [[NSArray alloc] initWithArray:[[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDefaultSequencesListFileName ofType:kDefaultSequencesListFileType] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"]];
    
    typeChooser = [[UIActionSheet alloc] initWithTitle:kTypeChooserTitle delegate:self cancelButtonTitle:kTypeChooserCancel destructiveButtonTitle:nil otherButtonTitles:kTypeChooserCustomName,kTypeChooserDefaultName,kTypeChooserDropboxName, nil];
    
    [customTxtView setDelegate:self];
    
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    
    doneTypingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneTypingBtn setTitle:@"Done Typing" forState:UIControlStateNormal];
    doneTypingBtn.frame = CGRectMake(customTxtView.frame.origin.x, customTxtView.frame.origin.y+customTxtView.frame.size.height, customTxtView.frame.size.width, self.view.frame.size.height/5);
    [doneTypingBtn addTarget:self action:@selector(doneTypingPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)loadForReads:(BOOL)forReads {
    isForReads = forReads;
}
//Picker View

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 0;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (isForReads)
        return [defaultReads count];
    else
        return [defaultSequences count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (isForReads)
        return [defaultReads objectAtIndex:row];
    else
        return [defaultSequences objectAtIndex:row];
}
//Basic Btns
- (IBAction)donePressed:(id)sender {
    [typeChooser showInView:self.view];
}
- (IBAction)backPressed:(id)sender {
    [delegate fileChosen:@""];
    [self dismissModalViewControllerAnimated:YES];
}
//Action Sheet 
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:typeChooser]) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if (buttonIndex == kTypeChooserCustom) {
                [delegate fileChosen:customTxtView.text];
            }
            else if (buttonIndex == kTypeChooserDefault) {
                if (isForReads) {
                    NSArray *arr = [[defaultReads objectAtIndex:[pickerView selectedRowInComponent:0]] componentsSeparatedByString:@"."];
                    
                    NSString *fileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[defaultReads objectAtIndex:[pickerView selectedRowInComponent:0]] ofType:[arr objectAtIndex:[arr count]-1]] encoding:NSUTF8StringEncoding error:nil];
                    
                    [delegate fileChosen:fileContents];
                }
                else {
                    NSArray *arr = [[defaultSequences objectAtIndex:[pickerView selectedRowInComponent:0]] componentsSeparatedByString:@"."];
                    
                    NSString *fileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[defaultSequences objectAtIndex:[pickerView selectedRowInComponent:0]] ofType:[arr objectAtIndex:[arr count]-1]] encoding:NSUTF8StringEncoding error:nil];
                    
                    [delegate fileChosen:fileContents];
                }
            }
            else if (buttonIndex == kTypeChooserDropbox) {
                
            }
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

//Text View
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.view addSubview:doneTypingBtn];
}

- (IBAction)doneTypingPressed:(id)sender {
    [doneTypingBtn removeFromSuperview];
    [customTxtView resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
