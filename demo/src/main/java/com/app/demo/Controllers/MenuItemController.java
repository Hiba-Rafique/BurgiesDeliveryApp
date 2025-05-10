package com.app.demo.Controllers;

import com.app.demo.models.MenuItem;
import com.app.demo.repository.MenuItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/menu")
public class MenuItemController {
        @Autowired
        private MenuItemRepository menuItemRepository;

        @GetMapping("/all")
        public List<MenuItem> getAllMenuItems() {
            return menuItemRepository.findAll();
        }

        @PostMapping("/add")
        public ResponseEntity<MenuItem> addMenuItem(@RequestBody MenuItem menuItem) {
                try {

                        MenuItem savedMenuItem = menuItemRepository.save(menuItem);
                        return new ResponseEntity<>(savedMenuItem, HttpStatus.CREATED); // 201 Created
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR); // Internal server error
                }
        }


        @DeleteMapping("/delete")
        public ResponseEntity<HttpStatus> deleteMenuItem(@RequestBody Map<String, String> body) {
                try {
                        String name = body.get("name");
                        Optional<MenuItem> menuItem = menuItemRepository.findByname(name);
                        if (menuItem.isPresent()) {
                                menuItemRepository.delete(menuItem.get());
                                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
                        } else {
                                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
                        }
                } catch (Exception e) {
                        e.printStackTrace(); // For debugging
                        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
                }
        }




        @PutMapping("/edit/{id}")
        public ResponseEntity<MenuItem> editMenuItem(@PathVariable("id") Long id, @RequestBody MenuItem menuItemDetails) {
                try {
                        Optional<MenuItem> existingMenuItem = menuItemRepository.findById(id);
                        if (existingMenuItem.isPresent()) {
                                MenuItem existingItem = existingMenuItem.get();


                                existingItem.setName(menuItemDetails.getName());
                                existingItem.setDescription(menuItemDetails.getDescription());
                                existingItem.setPrice(menuItemDetails.getPrice());


                                MenuItem updatedMenuItem = menuItemRepository.save(existingItem);
                                return new ResponseEntity<>(updatedMenuItem, HttpStatus.OK);
                        } else {
                                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
                        }
                } catch (Exception e) {
                        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
                }
        }
}



