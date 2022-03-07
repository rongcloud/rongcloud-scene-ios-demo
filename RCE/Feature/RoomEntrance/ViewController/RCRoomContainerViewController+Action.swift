//
//  UIViewController+RoomContainer.swift
//  RCE
//
//  Created by hanxiaoqing on 2022/2/21.
//

import RCSceneModular
import RCSceneService
import RCSceneFoundation

extension RCRoomContainerViewController: RCRoomContainerAction {
    
    func enableSwitchRoom() {
        let roomList = self.roomList
        let currentIndex = self.currentIndex
        self.collectionView.scrollable = roomList[currentIndex].switchable
    }
    
    func disableSwitchRoom() {
        self.collectionView.scrollable = false
    }
    
    func switchRoom(_ room: VoiceRoom) {
        var roomList = self.roomList
        let currentIndex = self.currentIndex
        if roomList[currentIndex].roomType == room.roomType {
            if let index = roomList.firstIndex(where: { $0.roomId == room.roomId }) {
                roomList[index] = room
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                            at: .centeredVertically,
                                            animated: true)
                return
            }
        }
        roomList = [room]
        self.collectionView.reloadData()
        if currentIndex == 0 {
            self.switchRoom()
        } else {
            self.currentIndex = 0
        }
        self.collectionView.scrollable = roomList[currentIndex].switchable
    }
    
    
}

extension RCRoomContainerViewController {
    /**
    func enableSwitchRoom() {
        collectionView.scrollable = roomList[currentIndex].switchable
    }

    func disableSwitchRoom() {
        collectionView.scrollable = false
    }
   
    func switchRoom(_ room: VoiceRoom) {
        if roomList[currentIndex].roomType == room.roomType {
            if let index = roomList.firstIndex(where: { $0.roomId == room.roomId }) {
                roomList[index] = room
                collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                            at: .centeredVertically,
                                            animated: true)
                return
            }
        }
        roomList = [room]
        collectionView.reloadData()
        if currentIndex == 0 {
            switchRoom()
        } else {
            currentIndex = 0
        }
        collectionView.scrollable = roomList[currentIndex].switchable
    }
     */
}
