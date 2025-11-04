// src/sitter/sitter.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Sitter } from './sitter.entity';
import { Repository } from 'typeorm';
import { SitterSetupDto } from './dto/sitter-setup.dto';
import { UserService } from 'src/user/user.service';

@Injectable()
export class SitterService {
  constructor(
    @InjectRepository(Sitter)
    private readonly sitterRepository: Repository<Sitter>,
    private readonly userService: UserService, // Inject UserService
  ) {}

  /**
   * Creates or updates a Sitter's setup profile.
   * We need the userId to link the profile.
   */
  async setupProfile(userId: number, setupDto: SitterSetupDto) {
    // 1. Find the user
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // 2. Find their existing sitter profile, or create a new one
    // We check using the relation
    let sitterProfile = await this.sitterRepository.findOne({
      where: { user: { id: userId } },
    });

    if (!sitterProfile) {
      sitterProfile = this.sitterRepository.create();
    }

    // 3. Map all data from the DTO to the entity
    sitterProfile.address = setupDto.address;
    sitterProfile.phoneNumber = setupDto.phoneNumber;
    sitterProfile.houseType = setupDto.houseType;
    sitterProfile.hasGarden = setupDto.hasGarden;
    sitterProfile.hasOtherPets = setupDto.hasOtherPets;
    sitterProfile.idDocumentUrl = setupDto.idDocumentUrl;
    sitterProfile.bio = setupDto.bio;
    sitterProfile.ratePerNight = setupDto.ratePerNight;

    // 4. Link the profile to the user
    sitterProfile.user = user;

    // 5. Save the sitter profile
    await this.sitterRepository.save(sitterProfile);

    // 6. Update the user's role to 'sitter'
    // (We use the string 'sitter' to match your user.entity.ts 'role: string')
    await this.userService.updateUserRole(user.id, 'sitter');

    return sitterProfile;
  }
}
