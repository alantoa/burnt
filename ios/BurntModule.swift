import ExpoModulesCore
import SPIndicator
import SPAlert
 
enum AlertPreset: String, Enumerable {
  case done
  case error
  case heart
  case spinner
  case custom

  func toSPAlertIconPreset(_ options: AlertOptions?) -> SPAlertIconPreset {
    switch self {
    case .done:
      return .done
    case .error:
      return .error
    case .heart:
      return .heart
    case .spinner:
      return .spinner
    case .custom:
      return .custom(UIImage.init( systemName: options?.iconName ?? "swift")!.withTintColor(options?.iconColor ?? .systemBlue, renderingMode: .alwaysOriginal))
        
    }
  }
}


enum AlertHaptic: String, Enumerable {
  case success
  case warning
  case error
  case none

  func toSPAlertHaptic() -> SPAlertHaptic {
    switch self {
    case .success:
      return .success
    case .warning:
      return .warning
    case .error:
      return .error
    case .none:
      return .none
    }
  }
}

struct AlertLayout: Record {
  @Field
  var iconSize: IconSize?
}

struct AlertOptions: Record {
  @Field
  var title: String = ""
  
  @Field
  var message: String?

  @Field
  var preset: AlertPreset = AlertPreset.done

  @Field
  var duration: TimeInterval?

  @Field
  var shouldDismissByTap: Bool = true

  @Field
  var haptic: AlertHaptic = .none

  @Field
  var layout: AlertLayout?
  
  @Field
  var iconName: String? = nil
  
  @Field
  var iconColor: UIColor = .systemGray
}

struct IconSize: Record {
  @Field
  var width: Int

  @Field
  var height: Int
}

struct ToastMargins: Record {
  @Field
  var top: CGFloat?

  @Field
  var left: CGFloat?

  @Field
  var bottom: CGFloat?

  @Field
  var right: CGFloat?
}

struct ToastLayout: Record {
  @Field
  var iconSize: IconSize?

  @Field
  var margins: ToastMargins?
}

struct ToastOptions: Record {
  @Field
  var title: String = ""
  
  @Field
  var message: String?

  @Field
  var preset: ToastPreset = ToastPreset.done

  @Field
  var duration: TimeInterval?

  @Field
  var layout: ToastLayout?

  @Field
  var shouldDismissByDrag: Bool = true

  @Field
  var haptic: ToastHaptic = .none

  @Field
  var from: ToastPresentSide = .top
  
  @Field
  var iosIconName: String? = nil
  
  @Field
  var iconColor: UIColor = .systemBlue
}

enum ToastHaptic: String, Enumerable {
  case success
  case warning
  case error
  case none

  func toSPIndicatorHaptic() -> SPIndicatorHaptic {
    switch self {
    case .success:
      return .success
    case .warning:
      return .warning
    case .error:
      return .error
    case .none:
      return .none
    }
  }
}

enum ToastPreset: String, Enumerable {
  case done
  case error
  case none
  case custom
  
  func toSPIndicatorPreset(_ options: ToastOptions?) -> SPIndicatorIconPreset? {
    switch self {
    case .done:
      return .done
    case .error:
      return .error
    case .custom:
        return .custom(UIImage.init( systemName: options?.iosIconName ?? "swift")!.withTintColor(options?.iconColor ?? .systemBlue, renderingMode: .alwaysOriginal))
    case .none:
      return .none
        
    }
  }
}

enum ToastPresentSide: String, Enumerable {
  case top
  case bottom

  func toSPIndicatorPresentSide() -> SPIndicatorPresentSide {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    }
  }
}

public class BurntModule: Module {
  public func definition() -> ModuleDefinition {
    Name("Burnt")

    AsyncFunction("toastAsync") { (options: ToastOptions) -> Void in
      let view : SPIndicatorView
      if(options.preset == .none){
        view = SPIndicatorView(title: options.title, message: options.message)
      } else if(options.preset == .custom){
        view = SPIndicatorView(title: options.title, message: options.message, preset: options.preset.toSPIndicatorPreset(options)!)
      }
      else{
        view = SPIndicatorView(title: options.title, message: options.message, preset: options.preset.toSPIndicatorPreset(nil)!)
      }

      if let duration = options.duration {
        view.duration = duration
      }

      if let icon = options.layout?.iconSize {
        view.layout.iconSize = .init(width: icon.width, height: icon.height)
      }
      
      view.dismissByDrag = options.shouldDismissByDrag

      view.presentSide = options.from.toSPIndicatorPresentSide();

      view.present(haptic: options.haptic.toSPIndicatorHaptic())
    }.runOnQueue(.main) 

    AsyncFunction("alertAsync")  { (options: AlertOptions) -> Void in
      let view : SPAlertView
      if(options.preset == .custom){
        view = SPAlertView(
          title: options.title,
          message: options.message,
          preset: options.preset.toSPAlertIconPreset(options))
      }
      else{
        view = SPAlertView(
          title: options.title,
          message: options.message,
          preset: options.preset.toSPAlertIconPreset(nil))
      }

      
        if let duration = options.duration {
          view.duration = duration
        }

        view.dismissByTap = options.shouldDismissByTap

        if let icon = options.layout?.iconSize {
          view.layout.iconSize = .init(width: icon.width, height: icon.height)
        }

        view.present(
          haptic: options.haptic.toSPAlertHaptic())
     }.runOnQueue(.main) 

    AsyncFunction("dismissAllAlertsAsync") {
      return SPAlert.dismiss()
    }.runOnQueue(.main) 
  }
}
