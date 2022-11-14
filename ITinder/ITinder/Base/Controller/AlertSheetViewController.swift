//
//  ImagePickerViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 17.08.2021.
//

import AVFoundation
import Foundation
import MobileCoreServices
import Photos
import UIKit
import UniformTypeIdentifiers

final class AlertSheetViewController: NSObject {
    
    static let shared = AlertSheetViewController()

    // MARK: - Properties

    private var controller: UIViewController?
    private var imageController: UIImagePickerController?

    var filePickedBlock: ((URL) -> Void)?
    var imagePickedBlock: ((UIImage) -> Void)?
    var selectImageHandler: ((_ image: UIImage) -> Void)?

    // MARK: - Constants

    enum Constants {
        static let alertForPhotoLibraryMessage = "У приложения нет доступа к вашим фотографиям. Чтобы разрешить доступ, коснитесь настроек и включите доступ к библиотеке фотографий"
        static let alertForCameraAccessMessage = "У приложения нет доступа к вашей камере. Чтобы разрешить доступ, коснитесь настроек и включите камеру."
        static let settingsBtnTitle = "Настройки"
        static let cancelBtnTitle = "Отмена"
    }

    // MARK: - Configure

    func showAlertSheet(items: [FileType], controller: UIViewController, _ image: UIImage? = nil) {
        self.controller = controller

        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menu.view.tintColor = UIColor.systemBlue

        let photo = UIAlertAction(title: FileType.photo.title, style: .default, handler: { (_: UIAlertAction!) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoCamera, vc: self.controller!)
        })

        let photoLibrary = UIAlertAction(title: FileType.photoLibrary.title, style: .default, handler: { (_: UIAlertAction!) -> Void in
            self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.controller!)
        })

        let file = UIAlertAction(title: FileType.file.title, style: .default, handler: { (_: UIAlertAction!) -> Void in
            self.documentPicker()
        })

        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: { (_: UIAlertAction!) -> Void in
        })

        if items.contains(.photo) {
            menu.addAction(photo)
        }
        if items.contains(.photoLibrary) {
            menu.addAction(photoLibrary)
        }
        if items.contains(.file) {
            menu.addAction(file)
        }
        menu.addAction(cancel)

        controller.present(menu, animated: true, completion: nil)
    }

    // MARK: - Authorisation Status

    func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.photoCamera {
                openPhotoCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                photoLibrary()
            }
        case .denied:
            addAlertForSettings(attachmentTypeEnum)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == PHAuthorizationStatus.authorized {
                    if attachmentTypeEnum == AttachmentType.photoCamera {
                        self.openPhotoCamera()
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary {
                        self.photoLibrary()
                    }
                } else {
                    self.addAlertForSettings(attachmentTypeEnum)
                }
            }
        case .restricted:
            addAlertForSettings(attachmentTypeEnum)
        default:
            break
        }
    }

    // MARK: - Photo camera picker

    func openPhotoCamera() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .camera
                self.controller?.present(myPickerController, animated: true, completion: nil)
            }
        }
    }

    // MARK: - Photo picker

    func photoLibrary() {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .photoLibrary
                self.controller?.present(myPickerController, animated: true, completion: nil)
            }
        }
    }

    // MARK: - File picker

    func documentPicker() {
        let supportedTypes: [UTType] = [UTType.pdf]
        let importMenu = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        controller?.present(importMenu, animated: true, completion: nil)
    }

    // MARK: - Settings alert

    func addAlertForSettings(_ attachmentTypeEnum: AttachmentType) {
        DispatchQueue.main.async {
            var alertTitle: String = ""
            if attachmentTypeEnum == AttachmentType.photoCamera {
                alertTitle = Constants.alertForCameraAccessMessage
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary {
                alertTitle = Constants.alertForPhotoLibraryMessage
            }

            let cameraUnavailableAlertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { _ -> Void in
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
            cameraUnavailableAlertController.addAction(cancelAction)
            cameraUnavailableAlertController.addAction(settingsAction)
            self.controller?.present(cameraUnavailableAlertController, animated: true, completion: nil)
        }
    }
}

// MARK: - Image picker delegate

extension AlertSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        controller?.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            imagePickedBlock?(image)
        }
        controller?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - File import delegate

extension AlertSheetViewController: UIDocumentPickerDelegate {
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        controller?.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileFormats = ["pdf"]

        if fileFormats.contains(url.pathExtension.lowercased()) {
            filePickedBlock?(url)
            return
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
