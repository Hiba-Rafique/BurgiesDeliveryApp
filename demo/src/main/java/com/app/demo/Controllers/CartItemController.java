package com.app.demo.Controllers;

import com.app.demo.models.CartItem;
import com.app.demo.repository.CartItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/cart-items")
@CrossOrigin(origins = "*") // Allow requests from Flutter
public class CartItemController {

    @Autowired
    private CartItemRepository cartItemRepository;

    @PostMapping
    public ResponseEntity<String> addCartItem(@RequestBody CartItem cartItem) {
        System.out.println("Received cart item: " + cartItem);

        cartItemRepository.save(cartItem);

        return ResponseEntity.ok("Item added to cart");
    }
}
