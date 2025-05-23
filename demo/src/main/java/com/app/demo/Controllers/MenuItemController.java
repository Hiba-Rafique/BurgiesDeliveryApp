package com.app.demo.Controllers;

import com.app.demo.models.MenuItem;
import com.app.demo.repository.MenuItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

@RestController
@RequestMapping("/menu")
public class MenuItemController {
        @Autowired
        private MenuItemRepository menuItemRepository;

        @GetMapping("/all")
        public List<MenuItem> getAllMenuItems() {
            return menuItemRepository.findAll();
        }

        @PostMapping(value = "/add", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
        public ResponseEntity<MenuItem> addMenuItem(
                @RequestParam("name") String name,
                @RequestParam("description") String description,
                @RequestParam("price") double price,
                @RequestParam("image") MultipartFile imageFile
        ) {
                try {
                        // Use absolute path for uploads directory (adjust this to your preferred path)
                        Path uploadsDir = Paths.get("uploads").toAbsolutePath();
                        Files.createDirectories(uploadsDir); // create uploads folder if it doesn't exist

                        String originalFilename = imageFile.getOriginalFilename();
                        String uniqueFilename = UUID.randomUUID() + "_" + originalFilename;
                        Path filePath = uploadsDir.resolve(uniqueFilename);

                        System.out.println("Saving file to: " + filePath.toString());

                        // Save the file
                        imageFile.transferTo(filePath.toFile());

                        // Generate public URL for the image (adjust based on how you serve static files)
                        String imageUrl = "/uploads/" + uniqueFilename;

                        // Create MenuItem and save to DB (constructor order fixed)
                        MenuItem menuItem = new MenuItem(name, description, price, imageUrl);
                        MenuItem savedMenuItem = menuItemRepository.save(menuItem);

                        return new ResponseEntity<>(savedMenuItem, HttpStatus.CREATED);
                } catch (Exception e) {
                        e.printStackTrace();
                        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
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



        @PutMapping("/edit/{name}")
        public ResponseEntity<MenuItem> editMenuItem(@PathVariable("name") String name, @RequestBody MenuItem menuItemDetails) {
                try {
                        Optional<MenuItem> existingMenuItem = menuItemRepository.findByName(name);  // <-- findByName instead of findById
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



