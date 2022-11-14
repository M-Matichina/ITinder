//
//  SearchViewController.swift
//  ITinder
//
//  Created by Mary Matichina on 21.08.2021.
///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

import DeviceKit
import Firebase
import Shuffle_iOS
import UIKit

class SearchViewController: BaseViewController {
    
    override class var storyboardName: String { return "Search" }

    // MARK: - Labels

    @IBOutlet private weak var titleInfoSearchViewLabel: UILabel!
    @IBOutlet private weak var descriptionInfoSearchViewLabel: UILabel!

    // MARK: - Views

    @IBOutlet private weak var iconImageView: UIImageView!

    // MARK: - Buttons

    private var dislikeButton: ITinderButton?
    private var likeButton: ITinderButton?

    // MARK: - Properties

    private weak var timer: Timer?
    private let timerInterval: TimeInterval = 10.0

    private var currentProfile = Profile()
    private let currentUser = Auth.auth().currentUser

    private let cardStack = SwipeCardStack()
    private let buttonStackView = ButtonStackView()

    private var personCards = [Profile]()
    private var personActions: [String: String]?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = nil

        configureHiddenAttributes()
        checkCurrentUserProfile()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }

    // MARK: - Methods

    private func checkCurrentUserProfile() {
        showLoader()
        guard let userId = currentUser?.uid else { return }

        ProfileDatabaseManager.shared.getProfile(for: userId) { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideLoader()
            switch result {
            case .success(let profile):
                self.currentProfile = profile
                if self.currentProfile.isFullData {
                    self.getPersonCardsData()
                } else {
                    self.needToFeelOutProfileState()
                }
            case .failure(let error):
                print("Ошибка: \(error)")
                self.needToFeelOutProfileState()
            }
        }
    }

    private func getPersonCardsData() {
        showLoader()

        guard let userId = currentUser?.uid else { return }

        personCards.removeAll()

        SearchDatabaseManager.shared.getListOfUsers(currentUserId: userId) { [weak self] result in
            guard let self = self else {
                return
            }
            self.hideLoader()
            switch result {
            case .success(let personsCard):
                self.personCards = personsCard
                if self.personCards.isEmpty {
                    self.emptyPersonCardState()
                    self.startTimer()
                } else {
                    self.configureHiddenAttributes()
                    self.stopTimer()
                }

                self.cardStack.delegate = self
                self.cardStack.dataSource = self
                self.buttonStackView.delegate = self

                self.configureButtonStackView()
                self.configureCardStackView()
                self.configureBackgroundGradient()
            case .failure(let error):
                print("Ошибка: \(error)")
            }
        }
    }

    private func needToFeelOutProfileState() {
        titleInfoSearchViewLabel.isHidden = false
        descriptionInfoSearchViewLabel.isHidden = false
        iconImageView.isHidden = false

        titleInfoSearchViewLabel.text = "Заполните все поля профиля"
        descriptionInfoSearchViewLabel.text = "После этого появятся карточки с потенциально интересными вам коллегами"
    }

    private func emptyPersonCardState() {
        titleInfoSearchViewLabel.isHidden = false
        descriptionInfoSearchViewLabel.isHidden = false
        iconImageView.isHidden = false

        titleInfoSearchViewLabel.text = "Вы посмотрели всех пользователей сервиса"
        descriptionInfoSearchViewLabel.text = "Как только новые интересные вам пользователи появятся, сервис отобразит информацию о них здесь"
    }

    private func configureHiddenAttributes() {
        titleInfoSearchViewLabel.isHidden = true
        descriptionInfoSearchViewLabel.isHidden = true
        iconImageView.isHidden = true
    }

    private func configureBackgroundGradient() {
        let backgroundGray = UIColor(red: 244 / 255, green: 247 / 255, blue: 250 / 255, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, backgroundGray.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func getLeftOrRigthPadding() -> CGFloat {
        switch Device.current.diagonal {
        case DeviceDiagonals.iPhone5Family.rawValue:
            return 55.0
        case DeviceDiagonals.iPhone6Family.rawValue:
            return 65.0
        default:
            return 80.0
        }
    }

    private func configureButtonStackView() {
        view.addSubview(buttonStackView)

        buttonStackView.anchor(
            left: view.safeAreaLayoutGuide.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.safeAreaLayoutGuide.rightAnchor,
            paddingLeft: getLeftOrRigthPadding(),
            paddingBottom: 16.0,
            paddingRight: getLeftOrRigthPadding()
        )

        dislikeButton = buttonStackView.dislikeButton
        likeButton = buttonStackView.likeButton

        if personCards.isEmpty {
            buttonStackView.isHidden = true
        } else {
            buttonStackView.isHidden = false
        }
    }

    private func configureCardStackView() {
        view.addSubview(cardStack)
        cardStack.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.safeAreaLayoutGuide.leftAnchor,
            bottom: buttonStackView.topAnchor,
            right: view.safeAreaLayoutGuide.rightAnchor
        )
    }

    @objc
    private func handleShift(_ sender: UIButton) {
        cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
    }

    // MARK: - Timer methods

    func startTimer() {
        if timer == nil {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
                guard let self = self else {
                    return
                }
                print("start timer")
                if self.personCards.isEmpty {
                    self.getPersonCardsData()
                }
            }
        }
    }

    func stopTimer() {
        if timer != nil {
            print("stop timer")
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: Data Source + Delegates

extension SearchViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.footerHeight = 80
        card.swipeDirections = [.left, .right]
        for direction in card.swipeDirections {
            card.setOverlay(ITinderCardOverlay(direction: direction), forDirection: direction)
        }
        let model = personCards[index]
        card.content = ITinderCardContentView(withImageUrl: model.imageUrl)
        card.footer = ITinderCardFooterView(withTitle: model.name, subtitle: model.position)

        return card
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return personCards.count
    }

    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.getPersonCardsData()
        }
    }

    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(personCards[index].name)")
    }

    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        print("Swiped \(direction) on \(personCards[index].name)")
        guard let userId = currentUser?.uid else { return }

        if direction == SwipeDirection.left {
            dislikeButton?.sendActions(for: .touchUpInside)
            SearchDatabaseManager.shared.updateAction(subjectId: userId, objectId: personCards[index].id, action: "dislike")
        } else {
            likeButton?.sendActions(for: .touchUpInside)
            SearchDatabaseManager.shared.updateAction(subjectId: userId, objectId: personCards[index].id, action: "like")

            let colleaguePerson = personCards[index]

            SearchDatabaseManager.shared.checkPersonAction(currentPersonId: userId, otherPersonId: colleaguePerson.id) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let personAction):
                    if personAction == "like" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.navigator.navigate(to: .match(currentPerson: self.currentProfile, colleaguePerson: colleaguePerson))
                        }
                    }
                case .failure(let error):
                    print("Ошибка: \(error)")
                }
            }
        }
    }

    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
        navigator.navigate(to: .detailUserProfile(personCards[index].id))
    }

    func didTapButton(button: ITinderButton) {
        switch button.tag {
        case 1:
            cardStack.swipe(.left, animated: true)
        case 2:
            cardStack.swipe(.right, animated: true)
        default:
            break
        }
    }
}
