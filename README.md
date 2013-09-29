# PhotoPayCloud SDK for iOS

PhotoPayCloud is a system for easy and efficient payment data extraction from various payment documents. Documents can be PDF invoices, Excel sheets, Word documents or photos of paper bills. PhotoPayCloud provides secure storage of these payment documents, as well as enables easy and simple payment method used for users of mobile banking applications.

This package contains client side SDK for accessing PhotoPayCloud web services on iOS.

This README document gives an overview of steps for integration of PhotoPayCloud SDK inside your application.

## Getting started 

Since this is a private git repository, the easiest way to stay up to date with the latest versions is to setup this repository as a git submodule inside your project's repository.

	cd <your-repo>
	git submodule add ... ppcloud-ios
	
This will clone the whole ppcloud-ios repository and check out master branch. Any subsequent pulls inside your repository will automatically pull changes in ppcloud-ios repository as well.

Inside ppcloud-ios there are two separate projects. 

PhotoPayCloudSDK is a project which builds the PhotoPayCloud framework. This is the framework which communicates with PhotoPay Cloud web services and you should use it inside your application. 

There is also a PhotoPayCloudDemo application which shows an example on how to do a proper integration. PhotoPayCloudDemo app additionaly uses AFNetworking library for network communication. If you use it in your application, the integration is even more simplified because you can simply copy AFNetworking wrappers for PhotoPayCloud into your application from PhotoPayCloudDemo app.

To run PhotoPayCloudDemo you need CocoaPods installed. To set up CocoaPods dependencies you should run:

	cd <PhotoPayCloudDemo-folder>
	pod install

## Setting up your Xcode workspace

The easiest way to use PhotoPayCloudSDK with your Xcode project is to add it into your Xcode workspace. Simply drag and drop PhotoPayCloudSDK.xcodeproj file to your workspace, below your project, on the same hierarchy level. 

After that, edit the sceme for building your application. Add __PhotoPayCloudFramework__ build target into your scheme, and set it to be built before your application's target. Also, disable "Parallelize Build" option. This will ensure PhotoPayCloudSDK is always rebuilt with the lastest updates before running your application. 

![Setting up your build scheme](Docs/xcode-scheme.png)

Now, start your application's build scheme. It will result with PhotoPayCloud.embeddedframework being created inside ppcloud-ios repository. Drag and drop it in the Frameworks group in your project. When asked, disable option "Copy items into destination group's folder"

![Adding PhotoPayCloud.embeddedframework to your project](Docs/xcode-add-framework.png)

Now you have everything set up to start the coding part. But first we can cover some of the basic PhotoPayCloudSDK architecture.

## Overview of PhotoPayCloudSDK architecture

Using PhotoPayCloudSDK primarily means collaborating with the following classes:

### PPPhotoPayCloudService

A singleton object responsible for performing all high level requests. PPPhotoPayCloudService object can perform the following tasks:

- uploading the document to PhotoPay Cloud web API
- uploading all pending documents which failed to upload in the last usage session
- deleting all pending documents
- obtaining the thumbnail and preview image of the document
- getting the actual document byte data
- deleting the document
- requesting all documents with a given status which in turn populate a UITableDataSource object.
- confirming the payment data values which were used in making the actual payment

These fatures are everything that's required to provide a well designed user experience.

### PPNetworkManager

PPNetworkManager is an abstract class for creating web requests for communicating with PhotoPayCloud Web API. It defines the interface which a concrete implementation must provide so that it can be used with PPPhotoPayCloudService object.

For example, PhotoPayCloudDemo application defines a concrete implementation of PPNetworkManager interface which uses AFNetworking library for managing network communication. If you use AFNetworking inside your application, consider using those classes. 

![Implementation of PPNetworkManager which uses AFNetworking](Docs/afppnetworkmanager.png)

### PPUser

An object which specifies the user of the PhotoPayCloud service. User is defined with the following properties:

- userId
- organizationId
- userType

userId must be unique for each user of your app. Organisation ID is the unique string ID of the organization which uses your app. User type can be _Person_, _Business_ or _Craft_, but _Person_ is typically used if not specified otherwise.

In example, for Erste Bank Serbia, use _Matični broj klijenta_ as userId, string "EBS" as organizationId, and leave userType to default value.

It's important to note that userId is never stored locally on the mobile device. The only user's data which is stored on the user's phone is MD5 hash of the userId, and it's only used for identifying documents which need to be uploaded until upload finishes, or until user deletes the document.

### PPDocument (and subclasses)

PPDocument is an ecapsulation of a document used in the payment process. A PPDocument object can be either PPLocalDocument (for example, an image obtained from the camera which still wasn't uploaded to PhotoPayCloud web service), or PPRemoteDocument (for example, the same image, but uploaded to server, processed and ready for payment). Furthermore, PPLocalDocument can be PPLocalImageDocument, when created from an UIImage object.

The most important properties of a PPDocument objects are documentType (png, jpeg, pdf, etc.), processing type, which defines what kind of processing will PhotoPayCloud server perform on this document, and a PPDocumentState. State defines what's happening with the document at the moment.

Each document starts as a PPLocalDocument in state Created, goes through a variety of states, for example, Uploading, Received, Processing, Processed, etc. For a document, the goal is to finish as a PPRemoteDocument in state Processed. When in this state, the document can be used to prepopulate a payment form with scanned payment data.

For example, for serbian invoices, documents are typically created as a PPLocalImageDocument subtype, with initializer:

	- (id)initWithImage:(UIImage*)inImage processingType:(PPDocumentProcessingType)inProcessingType 
	
PPDocumentProcessingType for photos of Serbian invoices is _PPDocumentProcessingTypeSerbianPhotoInvoice_

### PPDocumentsTableDataSource

PPPhotoPayCloudService object maintains it's own object which can be used as a UITableViewDataSource. The concrete implementation of this object can be overridden in your app, but the idea is that PPPhotoPayCloudService singleton object is responsible for maintaining a list of all documents of interest to the current user.

Division of documents in section inside PPDocumentsTableDataSource can be specified separately, but more on that later.

### Rough class diagram of most important classes

![Partial class diagram of PhotoPayCloudSDK](Docs/class-diag.png)

## Integration steps

### 1. Initializing PPPhotoPayCloudService object

The initialization method like the following should be called whenever a user logs in to the application. The method should specify specific data about the current user, as well as an object reposnsible for making network requests (PPNetworkManager object). For example, if you use AFNetworking, you can use PPAFNetworkManager class provided in the PhotoPayCloudDemo application, but you have to provide your own AFHTTPClient object.

	- (void)photoPayCloudLogin {
    	PPNetworkManager* networkManager = [[PPAFNetworkManager alloc] initWithHttpClient:[PPAppDelegate httpclient]];
		PPUser* user = [[PPUser alloc] initWithUserId:[[PPApp sharedApp] userId]
								   	   organizationId:@"EBS"];
    
    	[[PPPhotoPayCloudService sharedService] initializeForUser:user withNetworkManager:networkManager];
	}
	
### 2. Uninitializing PPPhotoPayCloudService object

Inverse method to initializatio should be performed every time the user logs out from the application. 

	- (void)photoPayCloudLogout {
    	[[PPPhotoPayCloudService sharedService] uninitialize];
	}
	
### 3. Checking for existing pending uploads

After the user logs in into the application, you should check if any pending uploads exist which didn't successfully complete. If they exist, the user should have the opportunity to continue those uploads, or delete them permanently.

	- (void)checkPhotoPayCloudUploads {
    	// check if PhotoPayCloudService was paused
    	if ([[PPPhotoPayCloudService sharedService] state] == PPPhotoPayCloudServiceStatePaused) {
        	
        	// if true, ask user to continue or abort paused requests
        	PPAlertView* alertView = [[PPAlertView alloc] initWithTitle:@"Some documents failed to upload")
                                                            	message:@"Would you like to continue uploading these documents?"
                                                         	 completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                             	NSError* __autoreleasing error = nil;
                                                             	if (buttonIndex == 0) {
                                                                 	[[PPPhotoPayCloudService sharedService] deletePendingDocumentsWithError:&error];
                                                             	} else if (buttonIndex == 1) {
                                                                 	[[PPPhotoPayCloudService sharedService] uploadPendingDocuments];
                                                             	}
                                                         	 }
                                                  	 cancelButtonTitle:@"Abort"
                                                  	 otherButtonTitles:@"Continue", nil];
        	[alertView show];
    	}
	}

### 4. Creating a PhotoPay Cloud Home View

PhotoPay Cloud Home View is a Table view which contains a list of all user's documents. This View also has a button which can start camera capture for taking a photo of a user's bill. Also, each cell in Table view can be pressed to open a Details view for a document represented by this cell.

You can design the Home view as you wish, but the easiest way to set up the basic functionality is to use your own subclass of PPDocumentsTableDataSource class for maintaining a list of PPDocument objects inside your Table view.

### 5. Specifying a Documents table data source

To use PPDocumentsTableDataSource as a data source for your UITableViews, you must subclass it and provide methods for creaing UITableViewCells. One example on how to do that is given in PhotoPayCloudDemo project and is a fairly standard way of achieving this. 

An instance method of PPDocumentsTableDataSource class which will definitely help for populating UITableViewCells with data about PPDocument objects is

	// Obtain document object for given index path
    PPDocument *document = [self itemForIndexPath:indexPath];
    
By default, this PPDocumentsTableDataSource object will automatically create one Table view section, and documents will be placed in this object sorted from the newest to the oldest. This behaviour can be overridden, but we'll cover that later.
    
