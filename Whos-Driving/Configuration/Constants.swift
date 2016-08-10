struct ErrorCodes {
    static let AuthErrorCode = 401 // error code returned when the auth token is invalid
    static let KillSwitchErrorCode = 403 // error code returned when a version is out of date and no longer supported
}

struct Facebook {
    static let DataKey = "data"
    static let EmailKey = "email"
    static let IdKey = "id"
    static let NameKey = "name"
    static let PictureKey = "picture"
    static let URLKey = "url"
}

struct Font {
    static let HelveticaNeueBold = "HelveticaNeue-Bold"
    static let HelveticaNeueLight = "HelveticaNeue-Light"
    static let HelveticaNeueLightItalic = "HelveticaNeue-LightItalic"
    static let HelveticaNeueMedium = "HelveticaNeue-Medium"
    static let HelveticaNeueRegular = "HelveticaNeue"
    static let HelveticaNeueThin = "HelveticaNeue-Thin"
    static let HelveticaNeueThinItalic = "HelveticaNeue-ThinItalic"
}

struct RequestHeaders {
    static let AcceptHeaderKey = "Accept"
    static let ApplicationJSON = "application/json"
    static let AuthorizationKey = "Authorization"
    static let ContentTypeKey = "Content-Type"
    static let UserAgentKey = "User-Agent"
}

struct SampleJSONFiles {
    static let FileExtension = "json"
    static let SampleEvents = "SampleEvents"
}

struct ServiceEndpoint {
    static let ConfirmUser = "confirm_user"
    static let CompleteAccountSetup = "profile/complete_account_setup"
    static let CurrentUserInvites = "profile/invite/"
    static let Devices = "devices.json/"
    static let DriverStatus = "driver_status/"
    static let Events = "events/"
    static let Feedback = "feedback/"
    static let HouseholdRiders = "profile/riders/"
    static let Invites = "invites/"
    static let Notifications = "/notifications/"
    static let NotificationsCurrent = "/notifications/current/"
    static let Profile = "profile/"
    static let ResetPassword = "reset_password"
    static let ResetPasswordToken = "reset_password_token"
    static let Riders = "riders/"
    static let SendResetPasswordInstructions = "send_password_reset_instructions"
    static let Sessions = "sessions/"
    static let TrustedDrivers = "trusted/drivers/"
    static let TrustedRiders = "trusted/riders/"
    static let UploadResources = "upload_resources/"
    static let Users = "users/"
    static let ValidateResetPasswordToken = "validate_reset_password_token"
}

struct ServiceRequest {
    static let EventScope = "scope"
    static let EventScopePast = "past"
}

struct ServiceResponse {
    static let AccountConfirmationToken = "confirmation_token"
    static let AccessToken = "token"
    static let AccountSetupComplete = "account_setup_complete"
    static let AddressKey = "address"
    static let AddressLine1Key = "line1"
    static let AddressLine2Key = "line2"
    static let CanDriveAvailabilityKey = "can_drive_availability"
    static let ChangesetNotice = "changeset_notice"
    static let CityKey = "city"
    static let CreatedAtKey = "created_at"
    static let DataKey = "data"
    static let DescriptionKey = "description"
    static let DriverActionsKey = "driver_actions"
    static let DrivingActionKey = "driving_action"
    static let DriverKey = "driver"
    static let DriverIdKey = "driver_id"
    static let DriverStatusResponseKey = "drivers_status_response"
    static let DriverStatusResponseFromKey = "driver_status_response_from"
    static let DriverStatusResponseToKey = "driver_status_response_to"
    static let DriversKey = "drivers"
    static let EmailKey = "email"
    static let EndTimeKey = "end_time"
    static let EventHistoryKey = "event_history"
    static let ExcludeHouseholdRiders = "exclude_household_riders"
    static let ExpirationKey = "expiration"
    static let FirstNameKey = "first_name"
    static let HouseHoldIdKey = "household_id"
    static let HouseHoldDriversKey = "household_drivers"
    static let HouseHoldRidersKey = "household_riders"
    static let IdKey = "id"
    static let ImageURLKey = "image_url"
    static let IncludeCurrentUserKey = "include_current_user"
    static let IncludeHouseholdDrivers = "include_household_drivers"
    static let InviteTokenKey = "invite_token"
    static let InviteTypeKey = "invite_type"
    static let InvitedDriverKey = "invited_driver"
    static let InvitingDriverKey = "inviting_driver"
    static let LastNameKey = "last_name"
    static let LastReadAtKey = "last_read_by_current_user_at"
    static let LicensedDriverKey = "licensed_driver"
    static let LocationKey = "location"
    static let MessageKey = "message"
    static let MetadataKey = "metadata"
    static let MobileNumberKey = "mobile_num"
    static let NameKey = "name"
    static let NoUserViewKey = "no_user_view"
    static let NoteKey = "note"
    static let NotificationKey = "notification"
    static let OwnerIdKey = "owner_id"
    static let PartnerKey = "partner"
    static let PasswordKey = "password"
    static let PasswordConfirmationKey = "password_confirmation"
    static let RelationshipType = "relationship_type"
    static let ResetPasswordTokenKey = "reset_password_token"
    static let ResourceKey = "resource"
    static let ResourcePathKey = "resource_path"
    static let RidersKey = "riders"
    static let SelectableDriversFromKey = "selectable_drivers_from"
    static let SelectableDriversToKey = "selectable_drivers_to"
    static let SelectableRidersFromKey = "selectable_riders_from"
    static let SelectableRidersToKey = "selectable_riders_to"
    static let StartTimeKey = "start_time"
    static let StatusKey = "status"
    static let StatusDetailKey = "status_detail"
    static let StatusMessageKey = "status_message"
    static let S3BucketNameKey = "s3_bucket_name"
    static let StateKey = "state"
    static let StatsKey = "stats"
    static let TimeStampKey = "timestamp"
    static let TokenKey = "token"
    static let TravelFromDetailsKey = "travel_from_details"
    static let TravelToDetailsKey = "travel_to_details"
    static let UpdatedAtKey = "updated_at"
    static let UserTypeKey = "user_type"
    static let UsersKey = "users"
    static let ValidTokenKey = "valid_token"
    static let ZipKey = "zip"
}

struct StaticContentEndpoint {
    static let About = "about"
    static let Privacy = "privacy"
    static let Terms = "terms"
}

struct USStates {
    static let StateAbbreviationKey = "StateAbbreviation"
    static let StateNameKey = "StateName"
}